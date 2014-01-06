# -*- encoding : utf-8 -*-

module RLetters
  module Documents
    # Code for generating a list of words (or ngrams) for a +Document+
    class WordList
      # Initialize a word list generator for the given document
      #
      # This function also supports returning a stemmed or lemmatized list
      # of words.
      #
      # @param [Hash] options options for generating the word list
      # @option options [Symbol] :stemming If set to +:stem+, pass the words
      #   through a Porter stemmer before returning them.  If set to +:lemma+,
      #   pass them through the Stanford NLP lemmatizer, if available.  The
      #   NLP lemmatizer is much slower, as it requires accessing the fulltext
      #   of the document rather than reconstructing from the term vectors.
      # @option options [Integer] :ngrams If set, return ngrams rather than
      #   single words.  Can be set to any integer >= 1.
      def initialize(options = {})
        @options = options
        @options.reverse_merge!(ngrams: 1, stemming: nil)
      end

      # The word list for this document
      #
      # @param [String] uid the UID of the document to operate on
      # @return [Array<String>] the words in the document, in word order,
      #   possibly stemmed or lemmatized
      # @example Get the words for a given document
      #   RLetters::Documents::WordList.new.words_for('gutenberg:3172')
      #   # => ['the', 'project', 'gutenberg', 'ebook', 'of', ...]
      def words_for(uid)
        word_list = if @options[:stemming] == :lemma && NLP_ENABLED
                      get_lemmatized_words(uid)
                    else
                      get_words(uid, @options[:stemming] == :stem)
                    end

        return word_list if !@options[:ngrams] || @options[:ngrams] <= 1
        word_list.each_cons(@options[:ngrams]).map { |a| a.join(' ') }
      end

      private

      # Get the word list for this document, possibly stemmed
      #
      # This method reconstructs the word list from doc.term_vectors.
      #
      # @api private
      # @param [Boolean] stem if true, stem words in list
      # @return [Array<String>] list of words for document
      def get_words(uid, stem = false)
        doc = Document.find(uid, term_vectors: true)

        # This converts from a hash to an array like:
        #  [[['word', pos], ['word', pos]], [['other', pos], ...], ...]
        word_list = doc.term_vectors.map do |k, v|
          [stem ? k.stem : k].product(v[:positions])
        end

        # Peel off one layer of inner arrays, sort it by the position, and
        # then return the array of just words in sorted order
        word_list.flatten(1).sort_by(&:last).map(&:first)
      end

      # Get the word list for this document, lemmatized
      #
      # This method hits doc.fulltext.
      #
      # @api private
      # @return [Array<String>] list of lemmatized words for document
      # :nocov:
      def get_lemmatized_words(uid)
        doc = Document.find(uid, fulltext: true)

        pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma)
        text = StanfordCoreNLP::Annotation.new(doc.fulltext)
        pipeline.annotate(text)

        text.get(:tokens).to_a.map { |tok| tok.get(:lemma).to_s }
      end
      # :nocov:
    end
  end
end
