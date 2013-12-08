
module Documents
  # Code for generating a list of words (or ngrams) for a +Document+
  module WordList
    extend ActiveSupport::Concern

    # Class methods to mix in to +Document+
    module ClassMethods
      # Get the list of words, in sorted order, for this document
      #
      # This function also supports returning a stemmed or lemmatized list
      # of words.
      #
      # @param [String] uid the UID of the document to operate on
      # @param [Hash] options options for generating the word list
      # @option options [Boolean] :stemming If set to +:stem+, pass the words
      #   through a Porter stemmer before returning them.  If set to +:lemma+,
      #   pass them through the Stanford NLP lemmatizer, if available.  The
      #   NLP lemmatizer is much slower, as it requires accessing the fulltext
      #   of the document rather than reconstructing from the term vectors.
      # @option options [Integer] :ngrams If set, return ngrams rather than
      #   single words.  Can be set to any integer >= 1.
      # @return [Array<String>] the words in the document, in word order,
      #   possibly stemmed or lemmatized
      # @example Get the words for a given document
      #   Document.word_list_for('gutenberg:3172')
      #   # => ['the', 'project', 'gutenberg', 'ebook', 'of', ...]
      def word_list_for(uid, options = {})
        if !NLP_ENABLED || options[:stemming] != :lemma
          doc = Document.find(uid, term_vectors: true)

          # This converts from a hash to an array like:
          #  [[['word', pos], ['word', pos]], [['other', pos], ...], ...]
          word_list = doc.term_vectors.map do |k, v|
            [options[:stemming] == :stem ? k.stem : k].product(v[:positions])
          end

          # Peel off one layer of inner arrays, sort it by the position, and
          # then return the array of just words in sorted order
          word_list = word_list.flatten(1).sort_by(&:last).map(&:first)
        else
          doc = Document.find(uid, fulltext: true)

          pipeline = StanfordCoreNLP.load(:tokenize, :ssplit, :pos, :lemma)
          text = StanfordCoreNLP::Annotation.new(doc.fulltext)
          pipeline.annotate(text)

          word_list = text.get(:tokens).to_a.map { |tok| tok.get(:lemma).to_s }
        end

        # Return ngrams if requested
        if options[:ngrams].blank? || options[:ngrams] <= 1
          return word_list
        end
        word_list.each_cons(options[:ngrams]).map { |a| a.join(' ') }
      end
    end
  end
end
