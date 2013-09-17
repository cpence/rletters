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
          # Block size for this dataset, in words
          #
          # If this attribute is zero, then we will read from +num_blocks+
          # instead.  Defaults to zero.
          #
          # @return [Integer] block size for this dataset
          attr_accessor :block_size

          # Split the dataset into how many blocks?
          #
          # If this attribute is zero, we will read from +block_size+ instead.
          # Defaults to zero.
          #
          # @return [Integer] number of blocks for splitting
          attr_accessor :num_blocks

          # Split blocks only within, or across documents?
          #
          # If this is set to true, then we will effectively concatenate all
          # the documents before splitting into blocks.  If false, we'll split
          # blocks on a per-document basis.  Defaults to true.
          #
          # @return [Boolean] whether to split blocks across documents
          attr_accessor :split_across

          # How many words in the list?
          #
          # If greater than the number of types in the dataset (or zero), then
          # return all the words.  Defaults to zero.
          #
          # @return [Integer] how many words to keep in the list
          attr_accessor :num_words
        end

        # Compute word frequency data for a given dataset
        #
        # @param [Dataset] datset the dataset for which to compute frequencies
        # @return [WordFrequencyAnalyzer] the computed frequency analyzer
        def compute_word_frequencies(dataset)
          convert_params!

          # Perform the analysis and return it
          WordFrequencyAnalyzer.new(dataset,
                                    block_size: block_size,
                                    num_blocks: num_blocks,
                                    num_words: num_words,
                                    split_across: split_across)
        end

        private

        # Convert all of the job parameters from strings to proper types
        #
        # Since the params are coming in from a form, they'll all be strings.
        # We need them as integer or boolean types, so convert them here.
        def convert_params!
          if block_size.blank?
            self.block_size = nil
          else
            self.block_size = Integer(block_size)
          end

          if num_blocks.blank?
            self.num_blocks = nil
          else
            self.num_blocks = Integer(num_blocks)
          end

          if num_words.blank?
            self.num_words = nil
          else
            self.num_words = Integer(num_words)
          end

          if split_across.blank?
            self.split_across = nil
          else
            if split_across == 'true'
              self.split_across = true
            else
              self.split_across = false
            end
          end
        end
      end

    end
  end
end
