# -*- encoding : utf-8 -*-

# Compute detailed word frequency information for a given dataset
class WordFrequencyAnalyzer

  # @return [Array<Hash>] The analyzed blocks of text (array of hashes of tfs)
  attr_reader :blocks

  # @return [Array<Hash>] Information about each block
  #   Each hash has :name, :types, and :tokens keys
  attr_reader :block_stats

  # @return [Array<String>] The list of words analyzed
  attr_reader :word_list

  # @return [Hash<String, Integer>] For each word, how many times that word
  #   occurs in the dataset
  attr_reader :tf_in_dataset

  # @return [Hash<String, Integer>] For each word, the number of documents in
  #   the dataset in which that word appears
  attr_reader :df_in_dataset

  # @return [Hash<String, Integer>] For each word, the number of documents in
  #   the entire Solr corpus in which that word appears
  attr_reader :df_in_corpus

  # @return [Integer] The number of tokens in the dataset
  attr_reader :num_dataset_tokens

  # @return [Integer] The number of types in the dataset
  attr_reader :num_dataset_types


  # Get the size of the entire Solr corpus.
  #
  # We need this value in order to compute tf/idf against the entire
  # corpus.  We compute it here and memoize it, as it requires a query to
  # the Solr database.
  #
  # @api private
  # @return [Integer] Size of the Solr database, in documents
  def num_corpus_documents
    @corpus_size ||= begin
                       solr_query = {}
                       solr_query[:q] = '*:*'
                       solr_query[:qt] = 'precise'
                       solr_query[:rows] = 1
                       solr_query[:start] = 0
                       
                       solr_response = Solr::Connection.find solr_query
                       
                       if solr_response["response"] &&
                           solr_response["response"]["numFound"]
                         solr_response["response"]["numFound"]
                       else
                         # FIXME: Should we raise an error here?
                         1
                       end
                     end
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
    if @split_across
      compute_block_size(@num_dataset_tokens)
    end

    # Set up the initial block
    @block_num = 0
    clear_block(false)
    
    # Process all of the documents
    @dataset.entries.each do |e|
      @current_doc = Document.find_with_fulltext e.shasum
      tv = @current_doc.term_vectors

      # If we aren't splitting across, then we have to completely clear
      # out all the count information for every document, and we have to
      # compute how many/how big the blocks should be for this document
      unless @split_across
        @block_num = 0
        compute_block_size(tv.values.map { |x| x["tf"] }.reduce(:+))
      end
      
      # Create a single array that has the words in the document sorted
      # by position
      sorted_words = []
      tv.each do |word, hash|
        next unless @word_list.include? word
        
        hash[:positions].each do |p|
          sorted_words << [ word, p ]
        end
      end
      sorted_words.sort! { |a, b| a[1] <=> b[1] }
      sorted_words.map! { |x| x[0] }
      
      # Do the processing for this document
      sorted_words.each do |word|
        @block[word] += 1
        @block_tokens += 1
        
        if @block[word] == 1
          @block_types += 1
        end
        
        @block_counter += 1
        
        # If the block size doesn't divide evenly into the number of blocks
        # that we want, we want to consume the remainder one at a time over
        # the course of all the blocks, and *not* leave it until the end, or
        # else we wind up with one block that contains all the remainder,
        # despite the fact that we were trying to divide evenly.
        check_size = @block_size
        if @num_remainder_blocks != 0
          check_size = @block_size + 1
        end
        
        if @block_counter >= check_size
          @num_remainder_blocks -= 1 if @num_remainder_blocks != 0
          clear_block
        end
      end
      
      # If we're not splitting across, we need to make sure the last block
      # for this doc, if there's anything in it, has been added to the list.
      if !@split_across && @block_counter != 0
        clear_block
      end
    end
    
    # If we are splitting across, we need to put the last block into the
    # list
    if @split_across && @block_counter != 0
      clear_block
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
    if options[:num_words] < 0
      options[:num_words] = 0
    end

    # Copy over the parameters to member variables
    @num_blocks = options[:num_blocks]
    @block_size = options[:block_size]
    @split_across = options[:split_across]
    @num_words = options[:num_words]

    # We will eventually set both @num_blocks and @block_size for our inner
    # loops, so we need to save which of these is the "primary" one, that
    # was set by the user
    if @num_blocks > 0
      @block_method = :count
    else
      @block_method = :words
    end
  end


  # Compute the df and tf for all the words in the dataset
  #
  # This function computes and sets @df_in_dataset, @tf_in_dataset, and
  # @df_in_corpus for all the words in the dataset.  Note that this
  # function ignores the @num_words parameter, as we need these tf values
  # to sort in order to obtain the most/least frequent words.
  #
  # All three of these variables are hashes, with the words as String keys
  # and the tf/df values as Integer values.
  #
  # Finally, this function also sets @num_dataset_types and @num_dataset_tokens,
  # as we can compute them easily here.
  #
  # Note that there is no such thing as @tf_in_corpus, as this would be
  # incredibly, prohibitively expensive and is not provided by Solr.
  #
  # @api private
  def compute_df_tf
    @df_in_dataset = {}
    @tf_in_dataset = {}
    @df_in_corpus = {}
    
    @dataset.entries.each do |e|
      doc = Document.find_with_fulltext e.shasum
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
  # This function takes the @num_words most (FIXME: or least) frequent words
  # from the @tf_in_dataset list and sets the array @word_list.
  #
  # @api private
  def pick_words    
    if @num_words == 0
      @word_list = @tf_in_dataset.keys
    else
      @word_list = @tf_in_dataset.to_a.sort { |a, b| b[1] <=> a[1] }.take(@num_words).map { |a| a[0] }
    end
  end


  # Get the name of this block
  #
  # @return [String] The name of this block
  def block_name
    if @split_across
      if @block_method == :count
        "Block #{@block_num}/#{@num_blocks} (across dataset)"
      else
        "Block #{@block_num} of #{@block_size} words (across dataset)"
      end
    else
      if @block_method == :count
        "Block #{@block_num}/#{@num_blocks} (within \"#{@current_doc.title}\")"
      else
        "Block #{@block_num} of #{@block_size} words (within \"#{@current_doc.title}\")"
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
      
      @block_stats << { :name => block_name, :types => @block_types,
        :tokens => @block_tokens }
      @blocks << @block.dup
    end
    
    @block_counter = 0
    @block_types = 0
    @block_tokens = 0
    
    # Set up an empty block
    @block = {}
    @word_list.each do |w|
      @block[w] = 0
    end
  end


  # Compute the block size parameters from the number of tokens
  #
  # This function takes whichever of the two block size numbers is primary
  # (by looking at @block_method), and computes the other given the number
  # of tokens (either in the document or in the dataset) and the details of
  # the splitting method.
  #
  # After this function is called, @num_blocks, @block_size, and
  # @num_remainder_blocks will all be set correctly.
  #
  # @api private
  # @param [Integer] num_tokens The number of tokens in our unit of analysis
  def compute_block_size(num_tokens)
    if @block_method == :count
      @block_size = (num_tokens / @num_blocks.to_f).floor
      @num_remainder_blocks = num_tokens - (@block_size * @num_blocks)
    else
      # FIXME: Right here is where we'd do BlockBigLast vs. BlockSmallLast for
      # the by-words block splitting.
      @num_blocks = (num_tokens / @block_size.to_f).ceil
      @num_remainder_blocks = 0
    end
  end
  
end

