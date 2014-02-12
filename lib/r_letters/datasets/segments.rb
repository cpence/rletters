# -*- encoding : utf-8 -*-

module RLetters
  module Datasets
    # Splits a dataset into text segments
    class Segments
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
        @segmenter = segmenter || RLetters::Documents::Segments.new

        @options = options
        @options.compact.reverse_merge!(split_across: true)
      end

      # Split the dataset into text segments
      #
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments
        @options[:split_across] ? segments_across : segments_within
      end

      private

      # Perform text segmentation, for splitting across documents
      #
      # @api private
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments_across
        @segmenter.reset!
        @dataset.entries.find_in_batches do |group|
          group.each do |entry|
            @segmenter.add(entry.uid)
          end
        end

        @segmenter.blocks
      end

      # Perform text segmentation, for splitting within documents
      #
      # @api private
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments_within
        [].tap do |ret|
          @dataset.entries.find_in_batches do |group|
            group.each do |entry|
              @segmenter.reset!
              @segmenter.add(entry.uid)
              @segmenter.blocks.each do |b|
                b.name += " (within document #{entry.uid})"
                ret << b
              end
            end
          end
        end
      end
    end
  end
end
