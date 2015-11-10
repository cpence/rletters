
module RLetters
  module Analysis
    module Frequency
      # Compute detailed word frequency information for a given dataset
      #
      # This class can compute all combinations of its input parameters, by
      # reconstructing the full text from the +offsets+ information in the
      # term vectors.
      #
      # @attribute dataset_segments
      #   @return [RLetters::Datasets::Segments] a segmenter for the dataset
      #     to analyze
      class FromPosition < RLetters::Analysis::Frequency::Base
        attribute :dataset_segments, RLetters::Datasets::Segments,
                  default: lambda { |analyzer, attribute|
                    RLetters::Datasets::Segments.new(
                      analyzer.parameter_hash.merge(progress: lambda do |p|
                        analyzer.progress && analyzer.progress.call((p * 0.8).to_i)
                      end))
                  }

        attribute :word_blocks, Array[RLetters::Documents::Block],
                  reader: :private, writer: :private

        # Analyze word frequency
        #
        # @return [self]
        def call
          # Reset in case this is reused
          dataset_segments.reset!

          # Get the word blocks from the segmenter
          self.word_blocks = dataset_segments.segments

          # Get the DFs in the dataset from the segmenter, and in the corpus
          # from the word lister
          self.df_in_dataset = dataset_segments.dfs
          self.df_in_corpus = dataset_segments.corpus_dfs

          # Convert the word arrays in the blocks from the list of words as found
          # in the document to { 'word' => count } hashes
          word_blocks.each do |b|
            b.words = Hash[b.words.group_by { |w| w }.map { |k, v| [k, v.size] }]
          end
          progress && progress.call(85)

          # Compute all df and tfs, and the type/token values for the dataset,
          # from the word blocks
          compute_df_tf
          progress && progress.call(90)

          # Pick out the set of words we'll analyze
          sorted_pairs = tf_in_dataset.to_a.sort { |a, b| b[1] <=> a[1] }
          self.word_list = sorted_pairs.map { |a| a[0] }
          cull_words
          progress && progress.call(93)

          # Convert from word blocks to the returned blocks by culling anything
          # not in the list of words to keep and adding zero values for words
          # that aren't present
          self.blocks = word_blocks.map do |b|
            b.words.reject { |k, _| !@word_list.include?(k) }
          end

          progress && progress.call(97)

          # Build block statistics
          self.block_stats = word_blocks.map do |b|
            { name: b.name,
              types: b.words.size,
              tokens: b.words.values.reduce(:+) }
          end
          progress && progress.call(100)

          self
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
        # @return [void]
        def compute_df_tf
          self.tf_in_dataset = {}
          word_blocks.each do |b|
            tf_in_dataset.merge!(b.words) { |_, v1, v2| v1 + v2 }
          end

          self.num_dataset_types = tf_in_dataset.size
          self.num_dataset_tokens = tf_in_dataset.values.reduce(:+)
        end
      end
    end
  end
end
