# frozen_string_literal: true

module RLetters
  # Code for manipulating datasets and the documents they contain
  module Datasets
    # Splits a dataset into text segments
    #
    # @!attribute dataset
    #   @return [Dataset] The dataset to analyze
    # @!attribute document_segmenter
    #   @return [RLetters::Documents::Segments] The document segmenter used to
    #     create these segments
    # @!attribute split_across
    #   @return [Boolean] if true, split across documents in the dataset,
    #     otherwise split only within documents
    # @!attribute progress
    #   @return [Proc] if set, a function to call with percentage of
    #     completion (one integer parameter)
    # @!attribute [r] dfs
    #   Return the document frequencies for the words in this dataset
    #
    #   @return [Hash<String, Integer>] a mapping from words to the number of
    #     documents in this dataset in which the word appears
    # @!attribute corpus_dfs
    #   @return [Hash<String, Integer>] A hash where the keys are the words in
    #     the dataset and the values are the document frequencies in the
    #     entire corpus (the number of documents in the corpus in which the
    #     word appears).
    class Segments
      include Virtus.model(strict: true, required: false, nullify_blank: true)
      include VirtusExt::ParameterHash

      attribute :dataset, Dataset, required: true
      attribute(:document_segmenter, RLetters::Documents::Segments,
                default: lambda do |segmenter, _|
                  RLetters::Documents::Segments.new(segmenter.parameter_hash)
                end)
      attribute :split_across, Boolean, default: true
      attribute :progress, Proc

      attribute :dfs, Hash[String => Integer], writer: :private
      attribute :corpus_dfs, Hash[String => Integer], writer: :private

      # Split the dataset into text segments
      #
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments
        split_across ? segments_across : segments_within
      end

      # Reset the dataset segmenter
      #
      # @return [void]
      def reset!
        self.dfs = {}
        self.corpus_dfs = {}
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
          dfs[w] ||= 0
          dfs[w] += 1
        end
      end

      # Perform text segmentation, for splitting across documents
      #
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments_across
        total = dataset.document_count.to_f
        document_segmenter.reset!

        enum = DocumentEnumerator.new(dataset: dataset, fl: 'uid')
        enum.each_with_index do |doc, i|
          document_segmenter.add(doc.uid)
          add_to_dfs(document_segmenter.words_for_last)
          progress&.call((i.to_f / total * 100.0).to_i)
        end

        # Update the corpus DFs from all these documents
        corpus_dfs.merge!(document_segmenter.corpus_dfs)

        progress&.call(100)

        document_segmenter.blocks
      end

      # Perform text segmentation, for splitting within documents
      #
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments_within
        total = dataset.document_count.to_f

        [].tap do |ret|
          enum = DocumentEnumerator.new(dataset: dataset, fl: 'uid')
          enum.each_with_index do |doc, i|
            document_segmenter.reset!
            document_segmenter.add(doc.uid)

            # Update the two DF variables
            add_to_dfs(document_segmenter.words_for_last)
            corpus_dfs.merge!(document_segmenter.corpus_dfs)

            document_segmenter.blocks.each do |b|
              b.name << I18n.t('lib.frequency.block_doc_suffix', title: doc.uid)
              ret << b
            end

            progress&.call((i.to_f / total * 100.0).to_i)
          end

          progress&.call(100)
        end
      end
    end
  end
end
