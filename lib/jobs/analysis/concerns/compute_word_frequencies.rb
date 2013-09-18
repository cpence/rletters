# -*- encoding : utf-8 -*-
require 'active_support/concern'

module Jobs
  module Analysis
    module Concerns

      # Compute word frequencies for a given dataset
      #
      # This concern just encapsulates obtaining the parameters you need for
      # a WordFrequencyAnalyzer and creates it.
      module ComputeWordFrequencies
        extend ActiveSupport::Concern

        included do
          # Compute word frequency data for a given dataset
          #
          # @param [Dataset] datset the dataset for which to compute frequencies
          # @param [Hash] args parameters for frequency analysis
          # @option args [String] block_size block size, in words
          #
          #   If this attribute is zero, then we will read from +num_blocks+
          #   instead.  Defaults to zero.
          # @option args [String] num_blocks number of blocks for splitting
          #
          #   If this attribute is zero, we will read from +block_size+ instead.
          #   Defaults to zero.
          # @option args [String] split_across whether to split blocks across
          #   documents
          #
          #   If this is set to true, then we will effectively concatenate all
          #   the documents before splitting into blocks.  If false, we'll split
          #   blocks on a per-document basis.  Defaults to true.
          # @option args [String] num_words how many words to keep in the list
          #
          #   If greater than the number of types in the dataset (or zero), then
          #   return all the words.  Defaults to zero.
          # @return [WordFrequencyAnalyzer] the computed frequency analyzer
          def self.compute_word_frequencies(dataset, args = { })
            convert_args!(args)

            # Perform the analysis and return it
            WordFrequencyAnalyzer.new(dataset,
                                      block_size: args[:block_size],
                                      num_blocks: args[:num_blocks],
                                      num_words: args[:num_words],
                                      split_across: args[:split_across])
          end

          private

          # Convert all of the job parameters from strings to proper types
          #
          # Since the params are coming in from a form, they'll all be strings.
          # We need them as integer or boolean types, so convert them here.
          def self.convert_args!(args)
            if args[:block_size].blank?
              args[:block_size] = nil
            else
              args[:block_size] = Integer(args[:block_size])
            end

            if args[:num_blocks].blank?
              args[:num_blocks] = nil
            else
              args[:num_blocks] = Integer(args[:num_blocks])
            end

            if args[:num_words].blank?
              args[:num_words] = nil
            else
              args[:num_words] = Integer(args[:num_words])
            end

            if args[:split_across].blank?
              args[:split_across] = nil
            else
              if args[:split_across] == 'true'
                args[:split_across] = true
              else
                args[:split_across] = false
              end
            end
          end

        end
      end

    end
  end
end
