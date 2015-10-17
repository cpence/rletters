
module RLetters
  module Analysis
    # Code for analyzing the frequency of words occurring in documents
    #
    # To provide inputs to many of the other analysis systems in RLetters,
    # the generation of parallel word frequency lists can be highly tweaked
    # and customized.
    module Frequency
      # A class to encapsulate an attribute that can be passed as a
      # space-separated list
      class SplitList < Virtus::Attribute
        # Coerce the list into an array if it's a string
        #
        # @param [Object] value the object to coerce
        # @return [Array] representation as an array
        def coerce(value)
          return nil if value.nil?
          return value if value.is_a?(Array)
          return value.list.split if value.is_a?(::Documents::StopList)
          return value.strip.split if value.is_a?(String)
          fail ArgumentError, "cannot create list from #{value.class}"
        end
      end

      # Interface for all word frequency analyzers
      #
      # This is an interface implemented by all word frequency analyzer
      # classes. Currently we have two, one of which analyzes quickly by simply
      # combining the `tf` values from the term vectors, and another which
      # analyzes much more slowly by reconstructing the full text from the
      # `offsets` variable.
      #
      # @see FromPosition
      # @see FromTF
      #
      # @!attribute progress
      #   @return [Proc] if set, a function to call with percentage of
      #     completion (one integer parameter)
      # @!attribute num_words
      #   @return [Integer] if set, only return frequency data for this many
      #     words; otherwise, return all words.  If +ngrams+ is available and
      #     set, this is a number of ngrams, not a number of words.
      # @!attribute all
      #   @return [Boolean] if set, ignore `num_words` and simply return all
      #     words (or ngrams)
      # @!attribute inclusion_list
      #   @return [String] if specified, then the  analyzer will only compute
      #     frequency information for the words that are specified in this
      #     list (which is space-separated).
      #
      #     If +ngrams+ is available and set, then this works differently.
      #     This list is assumed to be a space-separated list of single words.
      #     Ngrams will only be analyzed, then, if the ngram contains _at
      #     least one_ of the words found in +inclusion_list+.
      # @!attribute exclusion_list
      #   @return [String] if specified, then the  analyzer will *not* compute
      #     frequency information for the words that are specified in this
      #     list (which is space-separated).
      #
      #     If +ngrams+ is available and set, then this works differently.
      #     This list is assumed to be a space-separated list of single words.
      #     If an ngram contains _any of the words_ in this list, then it will
      #     not be analyzed.
      # @!attribute stop_list
      #   @return [Documents::StopList] if specified, then the analyzer will
      #     *not* compute frequency information for the words that appear
      #     within this stop list.  Cannot be used if +ngrams+ is set.
      # @!attribute [r] blocks
      #   @return [Array<Hash<String, Integer>>] The analyzed blocks of text
      #    (array of hashes of term frequencies)
      # @!attribute [r] block_stats
      #   Information about each block.
      #
      #   Each hash in this array (one per block) has :name, :types, and
      #   :tokens keys.
      #
      #   @return [Array<Hash>] Block information
      # @!attribute [r] word_list
      #   @return [Array<String>] The list of words (or ngrams) analyzed
      # @!attribute [r] tf_in_dataset
      #   @return [Hash<String, Integer>] For each word (or ngram), how many
      #     times that word occurs in the dataset
      # @!attribute [r] df_in_dataset
      #   @return [Hash<String, Integer>] For each word (or ngram), the number
      #     of documents in the dataset in which that word appears
      # @!attribute [r] num_dataset_tokens
      #   @return [Integer] The number of tokens in the dataset.  If `ngrams`
      #     is set, this is the number of ngrams.
      # @!attribute [r] num_dataset_types
      #   @return [Integer] The number of types in the dataset.  If `ngrams`
      #     is set, this is the number of distinct ngrams.
      # @!attribute [r] df_in_corpus
      #   @return [Hash<String, Integer>] For each word (or ngram), the number
      #     of documents in the entire corpus in which that word appears
      class Base
        include Service
        include Virtus.model(strict: true, required: false,
                             nullify_blank: true)

        attribute :progress, Proc
        attribute :num_words, Integer, default: 0
        attribute :all, Boolean, default: false
        attribute :inclusion_list, SplitList
        attribute :exclusion_list, SplitList
        attribute :stop_list, SplitList

        attribute :blocks, Array[Hash], writer: :private
        attribute :block_stats, Array[Hash], writer: :private
        attribute :word_list, Array[String], writer: :private
        attribute :tf_in_dataset, Hash[String => Integer], writer: :private
        attribute :df_in_dataset, Hash[String => Integer], writer: :private
        attribute :num_dataset_tokens, Integer, writer: :private
        attribute :num_dataset_types, Integer, writer: :private
        attribute :df_in_corpus, Hash[String => Integer], writer: :private

        protected

        # Throw an exception if any of the attribute values are invalid
        #
        # @return [void]
        def validate!
          # Look for the "all n-grams" option and use it to override the
          # number of words
          self.num_words = 0 if all

          if num_words < 0
            fail ArgumentError, "number of words cannot be negative"
          end
        end

        # Cull `word_list` with the exclusion/inclusion lists
        #
        # Before this function is called, the `word_list` variable should be
        # set with the full list of words available in the document.  It then
        # consults `inclusion_list`, `exclusion_list`, `@stop_list`, and
        # `num_words` in order to build the list of words that should be
        # analyzed (which is saved into `word_list`, which is overwritten).
        #
        # @return [void]
        def cull_words
          # Exclusion list takes precedence over stop list, if both are somehow
          # specified
          excluded = exclusion_list || stop_list || nil
          included = inclusion_list || nil

          # Exclude/include by checking overlap bewteen the words in the n-gram
          # and the words in the word list
          if excluded
            word_list.select! { |w| (w.split & excluded).empty? }
          elsif included
            word_list.reject! { |w| (w.split & included).empty? }
          end

          # Take the number of words that the user requests
          self.word_list = word_list.take(num_words) if num_words != 0
        end
      end
    end
  end
end
