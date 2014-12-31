
module RLetters
  module Analysis
    # Code for analyzing the frequency of words occurring in documents
    #
    # To provide inputs to many of the other analysis systems in RLetters,
    # the generation of parallel word frequency lists can be highly tweaked
    # and customized.
    module Frequency
      # Interface for all word frequency analyzers
      #
      # This is an interface implemented by all word frequency analyzer
      # classes. Currently we have two, one of which analyzes quickly by simply
      # combining the `tf` values from the term vectors, and another which
      # analyzes much more slowly by reconstructing the full text from the
      # `offsets` variable.
      #
      # @see PositionAnalyzer
      # @see TFAnalyzer
      #
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
        attr_reader :blocks, :block_stats, :word_list, :tf_in_dataset,
                    :df_in_dataset, :num_dataset_tokens, :num_dataset_types,
                    :df_in_corpus

        protected

        # Set the options from the options hash and normalize their values
        #
        # This function takes all available parameters to a word frequency
        # analyzer and cleans up their values. It sets the values `@num_words`,
        # `@inclusion_list`, `@exclusion_list`, and `@stop_list`.
        #
        # @api private
        # @param [Hash] options Parameters for how to compute word frequency
        # @return [void]
        def normalize_options(options)
          # Lower bound on number of words, default to zero
          @num_words = [0, options[:num_words] || 0].max

          # Look for the "all n-grams" option
          if options[:all] == '1'
            @num_words = 0
          end

          # Strip and split the lists of words
          if options[:inclusion_list]
            options[:inclusion_list].strip!
            options[:inclusion_list] = nil if options[:inclusion_list].empty?
          end
          if options[:exclusion_list]
            options[:exclusion_list].strip!
            options[:exclusion_list] = nil if options[:exclusion_list].empty?
          end

          @inclusion_list = @exclusion_list = nil
          @inclusion_list = options[:inclusion_list].split if options[:inclusion_list]
          @exclusion_list = options[:exclusion_list].split if options[:exclusion_list]

          # Make sure stop_list is the right type
          @stop_list = nil
          @stop_list = options[:stop_list].list.split if options[:stop_list]
        end

        # Cull `@word_list` with the exclusion/inclusion lists
        #
        # Before this function is called, the `@word_list` variable should be
        # set with the full list of words available in the document.  It then
        # consults `@inclusion_list`, `@exclusion_list`, `@stop_list`, and
        # `@num_words` in order to build the list of words that should be
        # analyzed (which is saved into `@word_list`, which is overwritten).
        #
        # @api private
        # @return [void]
        def cull_words
          # Exclusion list takes precedence over stop list, if both are somehow
          # specified
          excluded = @exclusion_list || @stop_list || nil
          included = @inclusion_list || nil

          # Exclude/include by checking overlap bewteen the words in the n-gram
          # and the words in the word list
          if excluded
            @word_list.select! { |w| (w.split & excluded).empty? }
          elsif included
            @word_list.reject! { |w| (w.split & included).empty? }
          end

          # Take the number of words that the user requests
          @word_list = @word_list.take(@num_words) if @num_words != 0
        end
      end
    end
  end
end
