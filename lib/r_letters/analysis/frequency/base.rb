
module RLetters
  module Analysis
    # Code for analyzing the frequency of words occurring in documents
    #
    # To provide inputs to many of the other analysis systems in RLetters,
    # the generation of parallel word frequency lists can be highly tweaked
    # and customized.
    module Frequency
      # Syntactic sugar for calling Base.call
      #
      # @return [RLetters::Analysis::Frequency::Base] analyzer class
      def self.call(*args)
        Base.call(*args)
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
      # @!attribute dataset
      #   @return [Dataset] the dataset to analyze
      # @!attribute progress
      #   @return [Proc] if set, a function to call with percentage of
      #     completion (one integer parameter)
      # @!attribute block_size
      #   @return [Integer] block size, in words
      #
      #   If this attribute is zero, then we will read from `num_blocks`
      #   instead.  Defaults to zero.
      # @!attribute num_blocks
      #   @return [Integer] number of blocks for splitting
      #
      #   If this attribute is zero, we will read from `block_size` instead.
      #   Defaults to zero.
      # @!attribute split_across
      #   @return [Boolean] whether to split blocks across documents
      #
      #   If this is set to true, then we will effectively concatenate all
      #   the documents before splitting into blocks.  If false, we'll
      #   split blocks on a per-document basis.  Defaults to true.
      # @!attribute last_block
      #   @return [Symbol] this parameter changes what will
      #     happen to the "leftover" words when +block_size+ is set.
      #
      #     [+:big_last+]      add them to the last block, making a block
      #       larger than +block_size+.
      #     [+:small_last+]    make them into their own block, making a block
      #       smaller than +block_size+.
      #     [+:truncate_last+] truncate those leftover words, excluding them
      #       from frequency computation.
      #     [+:truncate_all+]  truncate _every_ text to +block_size+, creating
      #       only one block per call to +#add+
      #
      #     The default is +:big_last+.
      # @!attribute ngrams
      #   @return [Integer] if set, return ngrams rather than single words.
      #     Can be set to any integer >= 1.  Defaults to 1.
      # @!attribute num_words
      #   @return [Integer] if set, only return frequency data for this many
      #     words; otherwise, return all words.  If +ngrams+ is available and
      #     set, this is a number of ngrams, not a number of words.
      # @!attribute stemming
      #   @return [Symbol] if set to +:stem+, pass the words through a Porter
      #     stemmer before returning them.  If set to +:lemma+, pass them
      #     through the Stanford NLP lemmatizer, if available.  The NLP
      #     lemmatizer is much slower, as it requires accessing the fulltext
      #     of the document rather than reconstructing from the term vectors.
      #     Defaults to no stemming.
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
        include VirtusExt::ParameterHash
        include VirtusExt::Validator

        attribute :dataset, Dataset, required: true
        attribute :progress, Proc
        attribute :block_size, Integer, default: 0
        attribute :num_blocks, Integer, default: 0
        attribute :ngrams, Integer, default: 1
        attribute :num_words, Integer, default: 0
        attribute :stemming, Symbol
        attribute :split_across, Boolean, default: true
        attribute :last_block, Symbol, default: :big_last
        attribute :all, Boolean, default: false
        attribute :inclusion_list, VirtusExt::SplitList
        attribute :exclusion_list, VirtusExt::SplitList
        attribute :stop_list, VirtusExt::StopList

        attribute :blocks, Array[Hash], writer: :private
        attribute :block_stats, Array[Hash], writer: :private
        attribute :word_list, Array[String], writer: :private
        attribute :tf_in_dataset, Hash[String => Integer], writer: :private
        attribute :df_in_dataset, Hash[String => Integer], writer: :private
        attribute :num_dataset_tokens, Integer, writer: :private
        attribute :num_dataset_types, Integer, writer: :private
        attribute :df_in_corpus, Hash[String => Integer], writer: :private

        # Create the correct frequency analyzer class and call it
        #
        # The `FromTF` analyzer is a quick-out option for a very specific set
        # of options. Look for those options here. Otherwise, build and call
        # `FromPosition`.
        #
        # @return [self]
        def call
          # Check for the quick-out
          if (num_blocks == 1 || (num_blocks == 0 && block_size == 0)) &&
             ngrams == 1 && stemming.nil?
            return FromTF.call(parameter_hash)
          end

          FromPosition.call(parameter_hash)
        end

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
