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
          # @param [Dataset] datset the dataset for which to compute
          #   frequencies
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
          #   the documents before splitting into blocks.  If false, we'll
          #   split blocks on a per-document basis.  Defaults to true.
          # @option args [String] num_words how many words to keep in the list
          #
          #   If greater than the number of types in the dataset (or zero),
          #   then return all the words.  Defaults to zero.
          # @option args [String] last_block how to treat the last block
          #
          #   Can be set to big_last, small_last, truncate_last, or
          #   truncate_all.  See the WordFrequencyAnalyzer for more
          #   information.
          # @option args [String] inclusion_list if set, list of words to find
          #
          #   If this attribute is set, then we'll only analyze the words that
          #   are specified here (separated by spaces), and no others.
          # @option args [String] stop_list if set, language of stop list
          #   to use
          # @option args [String] exclusion_list if set, list of words to
          #   exclude from analysis
          # @return [WordFrequencyAnalyzer] the computed frequency analyzer
          def self.compute_word_frequencies(dataset, args = { })
            convert_args!(args)

            # Perform the analysis and return it
            WordFrequencyAnalyzer.new(dataset,
                                      ngrams: args[:ngrams],
                                      block_size: args[:block_size],
                                      num_blocks: args[:num_blocks],
                                      num_words: args[:num_words],
                                      split_across: args[:split_across],
                                      last_block: args[:last_block],
                                      inclusion_list: args[:inclusion_list],
                                      stop_list: args[:stop_list],
                                      exclusion_list: args[:exclusion_list])
          end

          private

          # Convert all of the job parameters from strings to proper types
          #
          # Since the params are coming in from a form, they'll all be strings.
          # We need them as integer or boolean types, so convert them here.
          def self.convert_args!(args)
            if args[:ngrams].blank?
              args[:ngrams] = 1
            else
              args[:ngrams] = Integer(args[:ngrams])
            end

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
              if args[:split_across] == '1'
                args[:split_across] = true
              else
                args[:split_across] = false
              end
            end

            if args[:last_block].blank?
              args[:last_block] = nil
            else
              args[:last_block] = args[:last_block].to_sym
            end

            if args[:stop_list].blank?
              args[:stop_list] = nil
            else
              # Returns nil if the argument isn't found
              args[:stop_list] = Documents::StopList.find_by(language: args[:stop_list])
            end

            args[:inclusion_list] = nil if args[:inclusion_list].blank?
            args[:exclusion_list] = nil if args[:exclusion_list].blank?
          end

        end
      end

    end
  end
end
