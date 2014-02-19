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
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments(progress = nil)
        @options[:split_across] ? segments_across(progress) :
                                  segments_within(progress)
      end

      private

      # Perform text segmentation, for splitting across documents
      #
      # @api private
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments_across(progress)
        base = 0
        total = @dataset.entries.size.to_f

        @segmenter.reset!
        @dataset.entries.find_in_batches do |group|
          group.each_with_index do |entry, i|
            @segmenter.add(entry.uid)
            add_to_dfs(@segmenter.words_for_last)
            progress.call(((base + i).to_f / total * 100.0).to_i) if progress
          end

          base += group.size
        end

        progress.call(100) if progress

        @segmenter.blocks
      end

      # Perform text segmentation, for splitting within documents
      #
      # @api private
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      # @return [Array<RLetters::Documents::Block>] the text segments
      def segments_within(progress)
        base = 0
        total = @dataset.entries.size.to_f

        [].tap do |ret|
          @dataset.entries.find_in_batches do |group|
            group.each_with_index do |entry, i|
              @segmenter.reset!
              @segmenter.add(entry.uid)
              @segmenter.blocks.each do |b|
                b.name += " (within document #{entry.uid})"
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
