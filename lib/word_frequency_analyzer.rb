# -*- encoding : utf-8 -*-

# Compute detailed word frequency information for a given dataset
#
# @!attribute [r] blocks
#   @return [Array<Hash>] The analyzed blocks of text (array of hashes of tfs)
# @!attribute [r] block_stats
#   Information about each block.
#
#   Each hash in this array (one per block) has :name, :types, and :tokens
#   keys.
#
#   @return [Array<Hash>] Block information
# @!attribute [r] word_list
#   @return [Array<String>] The list of words analyzed
# @!attribute [r] tf_in_dataset
#   @return [Hash<String, Integer>] For each word, how many times that word
#     occurs in the dataset
# @!attribute [r] df_in_dataset
#   @return [Hash<String, Integer>] For each word, the number of documents in
#     the dataset in which that word appears
# @!attribute [r] df_in_corpus
#   @return [Hash<String, Integer>] For each word, the number of documents in
#     the entire Solr corpus in which that word appears
# @!attribute [r] num_dataset_tokens
#   @return [Integer] The number of tokens in the dataset
# @!attribute [r] num_dataset_types
#   @return [Integer] The number of types in the dataset
class WordFrequencyAnalyzer

  attr_reader :blocks, :block_stats, :word_list, :tf_in_dataset,
              :df_in_dataset, :df_in_corpus, :num_dataset_tokens,
              :num_dataset_types

  # Get the size of the entire Solr corpus.
  #
  # We need this value in order to compute tf/idf against the entire
  # corpus.  We compute it here and memoize it, as it requires a query to
  # the Solr database.
  #
  # @api private
  # @raise [Solr::ConnectionError] if the Solr connection fails
  # @return [Integer] Size of the Solr database, in documents
  def num_corpus_documents
    if @corpus_size.nil?
      solr_query = {}
      solr_query[:q] = '*:*'
      solr_query[:defType] = 'lucene'
      solr_query[:rows] = 1
      solr_query[:start] = 0

      search_result = Solr::Connection.search(solr_query)
      @corpus_size = search_result.num_hits
    end

    @corpus_size
  end

  # Create a new word frequency analyzer and analyze
  #
  # @api public
  # @param [Dataset] dataset The dataset to analyze
  # @param [Hash] options Parameters for how to compute word frequency
  # @option options [Integer] :block_size If set, split the dataset into blocks
  #   of this many words
  # @option options [Integer] :num_blocks If set, split the dataset into this
  #   many blocks of equal size
  # @option options [Boolean] :split_across If true, combine all the dataset
  #   documents together before splitting into blocks; otherwise, split into
  #   blocks only within a document
  # @option options [Integer] :num_words If set, only return frequency data for
  #   this many words; otherwise, return all words
  # @option options [Symbol] :last_block This parameter changes what will
  #   happen to the "leftover" words when +block_size+ is set.
  #
  #   [+:big_last+]      add them to the last block, making a block larger than
  #     +block_size+.
  #   [+:small_last+]    make them into their own block, making a block smaller
  #     than +block_size+.
  #   [+:truncate_last+] truncate those leftover words, excluding them from
  #     frequency computation.
  #   [+:truncate_all+]  truncate _every_ text to +block_size+, creating only
  #     one block per document (or, if +split_across+ is set, only one block
  #     period)
  #
  #   The default is +:big_last+.
  # @option options [String] :inclusion_list If specified, then the analyzer
  #   will only compute frequency information for the words that are specified
  #   in this list (which is space-separated).
  # @option options [String] :exclusion_list If specified, then the analyzer
  #   will *not* compute frequency information for the words that are specified
  #   in this list (which is space-separated).
  # @option options [Documents::StopList] :stop_list If specified, then the
  #   analyzer will *not* compute frequency information for the words that
  #   appear within this stop list.
  def initialize(dataset, options = {})
    # Save the dataset and options
    @dataset = dataset
    normalize_options(options)

    # Compute all df and tfs, and the type/token values for the dataset
    compute_df_tf

    # Pick out the set of words we'll analyze
    pick_words

    # Prep the data containers
    @blocks = []
    @block_stats = []

    # If we're split_across, we can now compute block_size from num_blocks
    # and vice versa
    compute_block_size(@num_dataset_tokens) if @split_across

    # Set up the initial block
    @block_num = 0
    clear_block(false)

    # Process all of the documents
    @dataset.entries.each do |e|
      @current_doc = Document.find(e.uid, term_vectors: true)
      tv = @current_doc.term_vectors

      # If we aren't splitting across, then we have to completely clear
      # out all the count information for every document, and we have to
      # compute how many/how big the blocks should be for this document
      unless @split_across
        @block_num = 0
        compute_block_size(tv.values.map { |x| x['tf'] }.reduce(:+))
      end

      # Create a single array that has the words in the document sorted
      # by position
      sorted_words = []
      tv.each do |word, hash|
        hash[:positions].each do |p|
          sorted_words << [word, p]
        end
      end
      sorted_words.sort! { |a, b| a[1] <=> b[1] }
      sorted_words.map! { |x| x[0] }

      # Do the processing for this document
      sorted_words.each do |word|
        # If we're truncating, then we want to be sure to stop when we hit the
        # calculated number of blocks
        if (@last_block == :truncate_last || @last_block == :truncate_all) &&
           @block_num == @num_blocks
          break
        end

        # Add this word to the block if we want it
        if @word_list.include? word
          @block[word] ||= 0
          @block[word] += 1
        end

        # Always increment the block counter and the number of tokens
        @type_counter[word] ||= true
        @block_tokens += 1
        @block_counter += 1

        # If we're doing :big_last for the last block, and this is the last
        # block, then we don't want to stop until we've digested all of the
        # words.  In that case, don't even check the block size.
        unless @last_block == :big_last && @block_num == (@num_blocks - 1)
          # If the block size doesn't divide evenly into the number of blocks
          # that we want, we want to consume the remainder one at a time over
          # the course of all the blocks, and *not* leave it until the end, or
          # else we wind up with one block that contains all the remainder,
          # despite the fact that we were trying to divide evenly.
          check_size = @block_size
          check_size = @block_size + 1 if @num_remainder_blocks != 0

          if @block_counter >= check_size
            @num_remainder_blocks -= 1 if @num_remainder_blocks != 0
            clear_block
          end
        end
      end

      # If we're not splitting across, we need to make sure the last block
      # for this doc, if there's anything in it, has been added to the list.
      clear_block if !@split_across && @block_counter != 0
    end

    # If we are splitting across, we need to put the last block into the
    # list
    clear_block if @split_across && @block_counter != 0
  end

  private

  # Set the options from the options hash and normalize their values
  #
  # @api private
  # @param [Hash] options Parameters for how to compute word frequency
  # @see WordFrequencyAnalyzer#initialize
  def normalize_options(options)
    # Set default values
    options[:num_blocks] ||= 0
    options[:block_size] ||= 0
    options[:split_across] = true if options[:split_across].nil?
    options[:num_words] ||= 0

    # If we get num_blocks and block_size, then the user's done something
    # wrong; just take block_size
    if options[:num_blocks] > 0 && options[:block_size] > 0
      options[:num_blocks] = 0
    end

    # Default to a single block unless otherwise specified
    if options[:num_blocks] <= 0 && options[:block_size] <= 0
      options[:num_blocks] = 1
    end

    # Make sure num_words isn't negative
    options[:num_words] = 0 if options[:num_words] < 0

    # Make sure last_block is a legitimate value
    allowed_last_block = [:big_last, :small_last,
                          :truncate_last, :truncate_all]
    unless allowed_last_block.include? options[:last_block]
      options[:last_block] = :big_last
    end

    # Make sure inclusion_list isn't blank
    options[:inclusion_list].strip! if options[:inclusion_list]
    options[:inclusion_list] = nil if options[:inclusion_list].blank?

    # Same for exclusion_list
    options[:exclusion_list].strip! if options[:exclusion_list]
    options[:exclusion_list] = nil if options[:exclusion_list].blank?

    # Make sure stop_list is the right type
    options[:stop_list] = nil unless options[:stop_list].is_a? Documents::StopList

    # Copy over the parameters to member variables
    @num_blocks = options[:num_blocks]
    @block_size = options[:block_size]
    @split_across = options[:split_across]
    @num_words = options[:num_words]
    @last_block = options[:last_block]
    @inclusion_list = options[:inclusion_list]
    @exclusion_list = options[:exclusion_list]
    @stop_list = options[:stop_list]

    # We will eventually set both @num_blocks and @block_size for our inner
    # loops, so we need to save which of these is the "primary" one, that
    # was set by the user
    if @num_blocks > 0
      @block_method = :count

      # We don't want any of the last_block logic if we're splitting by number
      # of blocks.
      @last_block = nil
    else
      @block_method = :words
    end
  end

  # Compute the df and tf for all the words in the dataset
  #
  # This function computes and sets +df_in_dataset+, +tf_in_dataset+,
  # and +df_in_corpus+ for all the words in the dataset.  Note that this
  # function ignores the +num_words+ parameter, as we need these tf values
  # to sort in order to obtain the most/least frequent words.
  #
  # All three of these variables are hashes, with the words as String keys
  # and the tf/df values as Integer values.
  #
  # Finally, this function also sets +num_dataset_types+ and
  # +num_dataset_tokens+, as we can compute them easily here.
  #
  # Note that there is no such thing as +tf_in_corpus+, as this would be
  # incredibly, prohibitively expensive and is not provided by Solr.
  #
  # @api private
  def compute_df_tf
    @df_in_dataset = {}
    @tf_in_dataset = {}
    @df_in_corpus = {}

    @dataset.entries.each do |e|
      doc = Document.find(e.uid, term_vectors: true)
      tv = doc.term_vectors

      tv.each do |word, hash|
        # Oddly enough, you'll get weird bogus values for words that don't
        # appear in your document back from Solr.  Not sure what's up with
        # that.
        @df_in_corpus[word] = hash[:df] unless hash[:df] == 0
        next if hash[:tf] == 0

        @tf_in_dataset[word] ||= 0
        @tf_in_dataset[word] += hash[:tf]

        @df_in_dataset[word] ||= 0
        @df_in_dataset[word] += 1
      end
    end

    @num_dataset_types ||= @tf_in_dataset.count
    @num_dataset_tokens ||= @tf_in_dataset.values.reduce(:+)
  end

  # Determine which words we'll analyze
  #
  # This function consults +inclusion_list+, and either takes the words
  # specified there, or the +num_words+ most frequent words from the
  # +tf_in_dataset+ list and sets the array +word_list+.  It also removes any
  # words specified in +exclusion_list+.
  #
  # @api private
  def pick_words
    if @inclusion_list
      @word_list = @inclusion_list.split
      return
    end

    # Exclusion list takes precedence over stop list, if both are somehow
    # specified
    excluded = []
    if @exclusion_list
      excluded = @exclusion_list.split
    elsif @stop_list
      excluded = @stop_list.list.split
    end

    if @num_words == 0
      @word_list = @tf_in_dataset.keys - excluded
    else
      sorted_pairs = @tf_in_dataset.to_a.sort { |a, b| b[1] <=> a[1] }
      sorted_pairs.reject! { |a| excluded.include?(a[0]) }
      @word_list = sorted_pairs.take(@num_words).map { |a| a[0] }
    end
  end

  # Get the name of this block
  #
  # @return [String] The name of this block
  def block_name
    if @split_across
      if @block_method == :count
        I18n.t('lib.wfa.block_count_dataset',
               num: @block_num, total: @num_blocks)
      else
        I18n.t('lib.wfa.block_size_dataset',
               num: @block_num, size: @block_size)
      end
    else
      if @block_method == :count
        I18n.t('lib.wfa.block_count_doc',
               num: @block_num, total: @num_blocks, title: @current_doc.title)
      else
        I18n.t('lib.wfa.block_size_doc',
               num: @block_num, size: @block_size, title: @current_doc.title)
      end
    end
  end

  # Reset all the current block information
  #
  # This clears all the block-related variables and sets us up for a new
  # block.  If the passed parameter is true, then also add the current block
  # to the block list before clearing it.
  #
  # @api private
  def clear_block(add = true)
    if add
      @block_num += 1

      @block_stats << { name: block_name, types: @type_counter.count,
                        tokens: @block_tokens }
      @blocks << @block.deep_dup
    end

    @block_counter = 0
    @block_tokens = 0

    @block = {}
    @type_counter = {}
  end

  # Compute the block size parameters from the number of tokens
  #
  # This function takes whichever of the two block size numbers is primary
  # (by looking at @block_method), and computes the other given the number
  # of tokens (either in the document or in the dataset) and the details of
  # the splitting method.
  #
  # After this function is called, @num_blocks, @block_size,
  # and @num_remainder_blocks will all be set correctly.
  #
  # @api private
  # @param [Integer] num_tokens The number of tokens in our unit of analysis
  def compute_block_size(num_tokens)
    if @block_method == :count
      @block_size = (num_tokens / @num_blocks.to_f).floor
      @num_remainder_blocks = num_tokens - (@block_size * @num_blocks)
    else
      if @last_block == :big_last || @last_block == :truncate_last
        @num_blocks = (num_tokens / @block_size.to_f).floor
      elsif @last_block == :small_last
        @num_blocks = (num_tokens / @block_size.to_f).ceil
      else # :truncate_all
        @num_blocks = 1
      end

      @num_remainder_blocks = 0
    end
  end

end
