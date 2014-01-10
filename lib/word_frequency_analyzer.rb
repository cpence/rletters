# -*- encoding : utf-8 -*-

# Compute detailed word frequency information for a given dataset
#
# @!attribute [r] blocks
#   @return [Array<Hash>] The analyzed blocks of text (array of hashes of term
#     frequencies)
# @!attribute [r] block_stats
#   Information about each block.
#
#   Each hash in this array (one per block) has :name, :types, and :tokens
#   keys.
#
#   @return [Array<Hash>] Block information
# @!attribute [r] word_list
#   @return [Array<String>] The list of words (or ngrams) analyzed
# @!attribute [r] tf_in_dataset
#   @return [Hash<String, Integer>] For each word (or ngram), how many times
#     that word occurs in the dataset
# @!attribute [r] df_in_dataset
#   @return [Hash<String, Integer>] For each word (or ngram), the number of
#     documents in the dataset in which that word appears
# @!attribute [r] df_in_corpus
#   @return [Hash<String, Integer>] For each word, the number of documents in
#     the entire Solr corpus in which that word appears.  If +ngrams+ is set,
#     this value will not be available.
# @!attribute [r] num_dataset_tokens
#   @return [Integer] The number of tokens in the dataset.  If +ngrams+ is set,
#     this is the number of ngrams.
# @!attribute [r] num_dataset_types
#   @return [Integer] The number of types in the dataset.  If +ngrams+ is set,
#     this is the number of distinct ngrams.
class WordFrequencyAnalyzer
  attr_reader :blocks, :block_stats, :word_list, :tf_in_dataset,
              :df_in_dataset, :df_in_corpus, :num_dataset_tokens,
              :num_dataset_types

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
  # @option options [Integer] :ngrams If set, look for n-grams of this size,
  #   instead of single words
  # @option options [Integer] :num_words If set, only return frequency data for
  #   this many words; otherwise, return all words.  If +ngrams+ is set, this
  #   is a number of ngrams, not a number of words.
  # @option options [Symbol] :stemming If set to +:stem+, stem words with the
  #   Porter stemmer before taking frequency.  If set to +:lemma+, lemmatize
  #   with the Stanford NLP (if availble; slow!).  If unset, do not stem.
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
  #
  #   If +ngrams+ is set, then this works differently.  This list is assumed
  #   to be a comma-separated list of single words.  Ngrams will only be
  #   analyzed, then, if the ngram contains _at least one_ of the words found
  #   in +inclusion_list+.
  # @option options [String] :exclusion_list If specified, then the analyzer
  #   will *not* compute frequency information for the words that are specified
  #   in this list (which is space-separated).
  #
  #   If +ngrams+ is set, then this works differently.  This list is assumed
  #   to be a comma-separated list of single words.  If an ngram contains _any
  #   of the words_ in this list, then it will not be analyzed.
  # @option options [Documents::StopList] :stop_list If specified, then the
  #   analyzer will *not* compute frequency information for the words that
  #   appear within this stop list.  Cannot be used if +ngrams+ is set.
  def initialize(dataset, options = {})
    # Save the dataset and options
    @dataset = dataset
    normalize_options(options)

    # Produce a word list generator
    word_list = RLetters::Documents::WordList.new(
      ngrams: options.delete(:ngrams),
      stemming: options.delete(:stemming))

    # Segment the dataset into text blocks
    split_across = options.delete(:split_across)
    segmenter = RLetters::Documents::Segmenter.new(word_list, options)
    text_segments = RLetters::Datasets::TextSegments.new(
      @dataset,
      segmenter,
      split_across: split_across)

    @word_blocks = text_segments.segments

    # Compute all df and tfs, and the type/token values for the dataset, from
    # the word blocks
    compute_df_tf

    # Pick out the set of words we'll analyze
    pick_words

    # Convert from word blocks to actual blocks
    @blocks = @word_blocks.map do |b|
      Hash[b.words.group_by { |w| w }.map { |k, v| [k, v.count] }].keep_if { |k, v| @word_list.include?(k) }
    end

    # Build block statistics
    @block_stats = @word_blocks.map do |b|
      { name: b.name, types: b.words.uniq.size, tokens: b.words.size }
    end
  end

  private

  # Set the options from the options hash and normalize their values
  #
  # @api private
  # @param [Hash] options Parameters for how to compute word frequency
  # @see WordFrequencyAnalyzer#initialize
  def normalize_options(options)
    # Set default values
    options.compact.reverse_merge!(num_blocks: 0,
                                   block_size: 0,
                                   ngrams: 1,
                                   num_words: 0)

    # Make sure stemming is a legitimate value
    unless [:stem, :lemma].include? options[:stemming]
      options[:stemming] = nil
    end

    # Make sure inclusion_list isn't blank
    options[:inclusion_list].try(:strip!)
    options[:inclusion_list] = nil if options[:inclusion_list].blank?

    # Same for exclusion_list
    options[:exclusion_list].try(:strip!)
    options[:exclusion_list] = nil if options[:exclusion_list].blank?

    # Make sure stop_list is the right type
    options[:stop_list] = nil unless options[:stop_list].is_a? Documents::StopList

    # No stop lists if ngrams is set
    if options[:stop_list] && options[:ngrams] != 1
      fail ArgumentError, 'cannot set both ngrams > 1 and stop_list'
    end

    # Copy over the parameters to member variables
    @ngrams = options[:ngrams].try(:lbound, 1)
    @num_words = options[:num_words].try(:lbound, 0)
    @stemming = options[:stemming]
    @inclusion_list = options[:inclusion_list].try(:split)
    @exclusion_list = options[:exclusion_list].try(:split)
    @stop_list = options[:stop_list]
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

    @word_blocks.each do |b|
      b.words.group_by { |w| w }.map { |k, v| [k, v.count] }.each do |(word, count)|
        @tf_in_dataset[word] ||= 0
        @tf_in_dataset[word] += count

        @df_in_dataset[word] ||= 0
        @df_in_dataset[word] += 1
      end
    end

    @num_dataset_types = @tf_in_dataset.count
    @num_dataset_tokens = @tf_in_dataset.values.reduce(:+)

    # Fetch @df_in_corpus, if available
    #
    # FIXME: This is really expensive, as we wind up looking up the documents
    # twice.  Is there some other way to do this?
    if @ngrams == 1
      @dataset.entries.each do |e|
        doc = Document.find(e.uid, term_vectors: true)
        doc.term_vectors.each do |word, hash|
          word = word.stem if @stemming == :stem

          # Oddly enough, you'll get weird bogus values for words that don't
          # appear in your document back from Solr.  Not sure what's up with
          # that.
          if hash[:df] > 0 && @df_in_corpus[word].blank?
            @df_in_corpus[word] = hash[:df]
          end
        end
      end
    end
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
    # If we have a word-list for 1-grams, this is easy
    if @inclusion_list.present? && @ngrams == 1
      @word_list = @inclusion_list
      return
    end

    # Exclusion list takes precedence over stop list, if both are somehow
    # specified
    excluded = []
    if @exclusion_list
      excluded = @exclusion_list
    elsif @stop_list
      excluded = @stop_list.list.split
    end

    included = []
    if @inclusion_list
      included = @inclusion_list
    end

    sorted_pairs = @tf_in_dataset.to_a.sort { |a, b| b[1] <=> a[1] }
    @word_list = sorted_pairs.map { |a| a[0] }

    if @ngrams == 1
      if excluded.present?
        # For 1-grams we can just use array difference.  If an inclusion list
        # was specified, we already did that up above and bailed early.
        @word_list -= excluded
      end
    else
      if excluded.present?
        # Keep any grams for which there is no overlap between the exclusion
        # list and the gram's words
        @word_list.select! { |w| (w.split & excluded).empty? }
      elsif included.present?
        # Reject any grams for which there is no overlap between the inclusion
        # list and the gram's words
        @word_list.reject! { |w| (w.split & included).empty? }
      end
    end

    @word_list = @word_list.take(@num_words) if @num_words != 0
  end
end
