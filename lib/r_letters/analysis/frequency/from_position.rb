
module RLetters
  module Analysis
    module Frequency
      # Compute detailed word frequency information for a given dataset
      #
      # This class can compute all combinations of its input parameters, by
      # reconstructing the full text from the +offsets+ information in the
      # term vectors.
      class FromPosition < RLetters::Analysis::Frequency::Base
        # Create a new word frequency analyzer and analyze
        #
        # @api public
        # @param [RLetters::Datasets::Segments] dataset_segments A segmenter
        #   for the dataset to analyze
        # @param [Proc] progress If set, a function to call with a percentage
        #   of completion (one Integer parameter)
        # @param [Hash] options Parameters for how to compute word frequency
        # @option options [Integer] :num_words If set, only return frequency
        #   data for this many words; otherwise, return all words.  If +ngrams+
        #   is set, this is a number of ngrams, not a number of words.
        # @option options [String] :inclusion_list If specified, then the
        #   analyzer will only compute frequency information for the words that
        #   are specified in this list (which is space-separated).
        #
        #   If +ngrams+ is set, then this works differently.  This list is
        #   assumed to be a comma-separated list of single words.  Ngrams will
        #   only be analyzed, then, if the ngram contains _at least one_ of the
        #   words found in +inclusion_list+.
        # @option options [String] :exclusion_list If specified, then the
        #   analyzer will *not* compute frequency information for the words
        #   that are specified in this list (which is space-separated).
        #
        #   If +ngrams+ is set, then this works differently.  This list is
        #   assumed to be a comma-separated list of single words.  If an ngram
        #   contains _any of the words_ in this list, then it will not be
        #   analyzed.
        # @option options [Documents::StopList] :stop_list If specified, then
        #   the analyzer will *not* compute frequency information for the words
        #   that appear within this stop list.  Cannot be used if +ngrams+ is
        #   set.
        def initialize(dataset_segments, progress = nil, options = {})
          # Save the options
          normalize_options(options)

          # Reset in case this is reused
          dataset_segments.reset!

          # Get the word blocks from the segmenter
          @word_blocks = dataset_segments.segments(->(p) { progress.call((p * 0.8).to_i) if progress })

          # Get the DFs in the dataset from the segmenter, and in the corpus
          # from the word lister
          @df_in_dataset = dataset_segments.dfs
          @df_in_corpus = dataset_segments.document_segmenter.word_list.corpus_dfs

          # Convert the word arrays in the blocks from the list of words as found
          # in the document to { 'word' => count } hashes
          @word_blocks.each do |b|
            b.words = Hash[b.words.group_by { |w| w }.map { |k, v| [k, v.size] }]
          end
          progress.call(85) if progress

          # Compute all df and tfs, and the type/token values for the dataset,
          # from the word blocks
          compute_df_tf
          progress.call(90) if progress

          # Pick out the set of words we'll analyze
          sorted_pairs = @tf_in_dataset.to_a.sort { |a, b| b[1] <=> a[1] }
          @word_list = sorted_pairs.map { |a| a[0] }
          cull_words
          progress.call(93) if progress

          # Convert from word blocks to the returned blocks by culling anything
          # not in the list of words to keep and adding zero values for words
          # that aren't present
          @blocks = @word_blocks.map do |b|
            b.words.reject { |k, _| !@word_list.include?(k) }
          end

          progress.call(97) if progress

          # Build block statistics
          @block_stats = @word_blocks.map do |b|
            { name: b.name,
              types: b.words.size,
              tokens: b.words.values.reduce(:+) }
          end
          progress.call(100) if progress
        end

        private

        # Compute the df and tf for all the words in the dataset
        #
        # This function computes and sets +df_in_dataset+ and +tf_in_dataset+,
        # for all the words in the dataset.  Note that this
        # function ignores the +num_words+ parameter, as we need these tf
        # values to sort in order to obtain the most/least frequent words.
        #
        # All three of these variables are hashes, with the words as String
        # keys and the tf/df values as Integer values.
        #
        # Finally, this function also sets +num_dataset_types+ and
        # +num_dataset_tokens+, as we can compute them easily here.
        #
        # Note that there is no such thing as +tf_in_corpus+, as this would be
        # incredibly, prohibitively expensive and is not provided by Solr.
        #
        # @api private
        # @return [void]
        def compute_df_tf
          @tf_in_dataset = {}
          @word_blocks.each do |b|
            @tf_in_dataset.merge!(b.words) { |_, v1, v2| v1 + v2 }
          end

          @num_dataset_types = @tf_in_dataset.size
          @num_dataset_tokens = @tf_in_dataset.values.reduce(:+)
        end
      end
    end
  end
end
