# frozen_string_literal: true

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
        attribute(:dataset_segments, RLetters::Datasets::Segments,
                  default: lambda do |analyzer, _|
                    RLetters::Datasets::Segments.new(
                      analyzer.parameter_hash.merge(progress: lambda do |p|
                        analyzer.progress&.call((p * 0.8).to_i)
                      end)
                    )
                  end)

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
          # in the document to { 'word' => count } hashes. Compute tf_in_dataset
          # en passant.
          self.tf_in_dataset = {}
          word_blocks.each do |b|
            b.words = Hash[b.words.group_by { |w| w }.map do |k, v|
              self.tf_in_dataset[k] ||= 0
              self.tf_in_dataset[k] += v.size

              [k, v.size]
            end]
          end
          progress&.call(85)

          # Sum up the tf_in_dataset values for our type/token counts
          self.num_dataset_types = tf_in_dataset.size
          self.num_dataset_tokens = tf_in_dataset.values.reduce(:+)
          progress&.call(90)

          # Pick out the set of words we'll analyze
          cull_words
          progress&.call(93)

          # Convert from word blocks to the returned blocks by culling anything
          # not in the list of words to keep and adding zero values for words
          # that aren't present
          self.blocks = word_blocks.map do |b|
            b.words.select { |k, _| @word_list.include?(k) }
          end

          progress&.call(97)

          # Build block statistics
          self.block_stats = word_blocks.map do |b|
            { name: b.name,
              types: b.words.size,
              tokens: b.words.values.reduce(:+) }
          end
          progress&.call(100)

          self
        end
      end
    end
  end
end
