
module RLetters
  # Code for manipulating datasets and the documents they contain
  module Datasets
    # Splits a dataset into text segments
    #
    # @!attribute [r] dfs
    #   Return the document frequencies for the words in this dataset
    #
    #   @return [Hash<String, Integer>] a mapping from words to the number of
    #     documents in this dataset in which the word appears
    # @!attribute [r] document_segmenter
    #   @return [RLetters::Documents::Segments] The document segmenter used to
    #     create these segments
    class Segments
      attr_reader :dfs, :document_segmenter

      # Create an object to split a dataset into text segments
      #
      # @param dataset [Dataset] the dataset to segment
      # @param segmenter [RLetters::Documents::Segments] a document segmenter
      #   (if +nil+, create default)
      # @param [Hash] options options for generating the word list
      # @option options [Symbol] :split_across [Boolean] if true, split across
      #   documents in the dataset, otherwise split only within documents
      def initialize(dataset, segmenter = nil, options = {})
        @dataset = dataset
        @document_segmenter = segmenter || RLetters::Documents::Segments.new
        @document_segmenter.reset!
        @dfs = {}

        @options = options.compact.reverse_merge(split_across: true)
      end

      # Split the dataset into text segments
      #
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments(progress = nil)
        if @options[:split_across]
          segments_across(progress)
        else
          segments_within(progress)
        end
      end

      # Reset the dataset segmenter
      #
      # @return [void]
      def reset!
        @dfs = {}
        @document_segmenter.reset!
      end

      private

      # Add the given list of words to the document frequency array
      #
      # This function piecewise constructs the word frequency in dataset for
      # a given document
      #
      # @param [Array<String>] words the words in one of the dataset's
      #   documents
      # @return [void]
      def add_to_dfs(words)
        words.each do |w|
          @dfs[w] ||= 0
          @dfs[w] += 1
        end
      end

      # Perform text segmentation, for splitting across documents
      #
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments_across(progress)
        base = 0
        total = @dataset.entries.size.to_f

        @document_segmenter.reset!
        @dataset.entries.find_in_batches do |group|
          group.each_with_index do |entry, i|
            @document_segmenter.add(entry.uid)
            add_to_dfs(@document_segmenter.words_for_last)
            progress.call(((base + i).to_f / total * 100.0).to_i) if progress
          end

          base += group.size
        end

        progress.call(100) if progress

        @document_segmenter.blocks
      end

      # Perform text segmentation, for splitting within documents
      #
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments_within(progress)
        base = 0
        total = @dataset.entries.size.to_f

        [].tap do |ret|
          @dataset.entries.find_in_batches do |group|
            group.each_with_index do |entry, i|
              @document_segmenter.reset!
              @document_segmenter.add(entry.uid)
              add_to_dfs(@document_segmenter.words_for_last)
              @document_segmenter.blocks.each do |b|
                b.name += I18n.t('lib.frequency.block_doc_suffix', title: entry.uid)
                ret << b
              end

              progress.call(((base + i).to_f / total * 100.0).to_i) if progress
            end

            base += group.size
          end

          progress.call(100) if progress
        end
      end
    end
  end
end
