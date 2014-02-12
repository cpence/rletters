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
# @!attribute [r] num_dataset_tokens
#   @return [Integer] The number of tokens in the dataset.  If +ngrams+ is set,
#     this is the number of ngrams.
# @!attribute [r] num_dataset_types
#   @return [Integer] The number of types in the dataset.  If +ngrams+ is set,
#     this is the number of distinct ngrams.
class WordFrequencyAnalyzer
  attr_reader :blocks, :block_stats, :word_list, :tf_in_dataset,
              :df_in_dataset, :num_dataset_tokens, :num_dataset_types

  # Create a new word frequency analyzer and analyze
  #
  # @api public
  # @param [RLetters::Datasets::Segments] dataset_segmenter A segmenter for
  #   the dataset to analyze
  # @param [Hash] options Parameters for how to compute word frequency
  # @option options [Integer] :num_words If set, only return frequency data for
  #   this many words; otherwise, return all words.  If +ngrams+ is set, this
  #   is a number of ngrams, not a number of words.
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
  def initialize(dataset_segmenter, options = {})
    # Save the options
    normalize_options(options)

    # Get the word blocks from the segmenter
    @word_blocks = dataset_segmenter.segments

    # Convert the word arrays in the blocks from the list of words as found
    # in the document to { 'word' => count } hashes
    @word_blocks.each do |b|
      b.words = Hash[b.words.group_by { |w| w }.map { |k, v| [k, v.count] }]
    end

    # Compute all df and tfs, and the type/token values for the dataset, from
    # the word blocks
    compute_df_tf

    # Pick out the set of words we'll analyze
    pick_words

    # Convert from word blocks to the returned blocks by culling anything not
    # in the list of words to keep
    @blocks = @word_blocks.map do |b|
      b.words.reject { |k, v| !@word_list.include?(k) }
    end

    # Build block statistics
    @block_stats = @word_blocks.map do |b|
      { name: b.name,
        types: b.words.size,
        tokens: b.words.values.reduce(:+) }
    end
  end

  private

  # Set the options from the options hash and normalize their values
  #
  # @api private
  # @param [Hash] options Parameters for how to compute word frequency
  # @see WordFrequencyAnalyzer#initialize
  def normalize_options(options)
    # Lower bound on number of words, default to zero
    @num_words = [0, options[:num_words] || 0].max

    # Strip and split the lists of words
    if options[:inclusion_list]
      options[:inclusion_list].strip!
      options[:inclusion_list] = nil if options[:inclusion_list].empty?
    end
    if options[:exclusion_list]
      options[:exclusion_list].strip!
      options[:exclusion_list] = nil if options[:exclusion_list].empty?
    end

    @inclusion_list = @exclusion_list = nil
    @inclusion_list = options[:inclusion_list].split if options[:inclusion_list]
    @exclusion_list = options[:exclusion_list].split if options[:exclusion_list]

    # Make sure stop_list is the right type
    options[:stop_list] = nil unless options[:stop_list].is_a? Documents::StopList
    @stop_list = nil
    @stop_list = options[:stop_list].list.split if options[:stop_list]
  end

  # Compute the df and tf for all the words in the dataset
  #
  # This function computes and sets +df_in_dataset+ and +tf_in_dataset+,
  # for all the words in the dataset.  Note that this
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
    @tf_in_dataset = {}
    all_words = []

    @word_blocks.each do |b|
      @tf_in_dataset.merge!(b.words) { |w, v1, v2| v1 + v2 }
      all_words += b.words.keys
    end

    @df_in_dataset = Hash[all_words.group_by { |w| w }.map { |k, v| [k, v.count] }]

    @num_dataset_types = @tf_in_dataset.count
    @num_dataset_tokens = @tf_in_dataset.values.reduce(:+)
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
    # Exclusion list takes precedence over stop list, if both are somehow
    # specified
    excluded = @exclusion_list || @stop_list || nil
    included = @inclusion_list || nil

    # Sort descending by frequency of occurrence
    sorted_pairs = @tf_in_dataset.to_a.sort { |a, b| b[1] <=> a[1] }
    @word_list = sorted_pairs.map { |a| a[0] }

    # Exclude/include by checking overlap bewteen the words in the n-gram
    # and the words in the word list
    if excluded
      @word_list.select! { |w| (w.split & excluded).empty? }
    elsif included
      @word_list.reject! { |w| (w.split & included).empty? }
    end

    # Take the number of words that the user requests
    @word_list = @word_list.take(@num_words) if @num_words != 0
  end
end
