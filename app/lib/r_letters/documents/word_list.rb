# frozen_string_literal: true

module RLetters
  module Documents
    # Code for generating a list of words (or ngrams) for a +Document+
    #
    # @!attribute ngrams
    #   @return [Integer] If set, return ngrams rather than single words. Can
    #     be set to any integer >= 1.  Defaults to 1.
    # @!attribute stemming
    #   @return [Symbol] If set to +:stem+, pass the words through a Porter
    #     stemmer before returning them.  If set to +:lemma+, pass them through
    #     a lemmatizer. Defaults to no stemming.
    # @!attribute corpus_dfs
    #   @return [Hash<String, Integer>] A hash where the keys are the words in
    #     the document and the values are the document frequencies in the
    #     entire corpus (the number of documents in the corpus in which the
    #     word appears).
    #   @note This will only return values for words appearing in the
    #     documents that have been scanned by +words_for+ since this word
    #     lister was created.
    class WordList
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :ngrams, Integer, default: 1
      attribute :stemming, Symbol

      attribute :corpus_dfs, Hash[String => Integer], writer: :private

      # The word list for this document
      #
      # @param [String] uid the UID of the document to operate on
      # @return [Array<String>] the words in the document, in word order,
      #   possibly stemmed or lemmatized
      def words_for(uid)
        word_list = get_words(uid)

        return word_list if ngrams <= 1
        word_list.each_cons(ngrams).map { |a| a.join(' ') }
      end

      private

      # Get the word list for this document, possibly stemmed or lemmatized
      #
      # @return [Array<String>] list of words for document
      def get_words(uid)
        doc = Document.find(uid, term_vectors: true)
        add_dfs(doc)

        # This converts from a hash to an array like:
        #  [[['word', pos], ['word', pos]], [['other', pos], ...], ...]
        word_list = doc.term_vectors.map do |k, v|
          k = case stemming
              when :stem
                k.stem
              when :lemma
                RLetters::Analysis::Lemmatizer.lemma(k).dup
              else
                k
              end

          [k].product(v[:positions])
        end

        # Peel off one layer of inner arrays, sort it by the position, and
        # then return the array of just words in sorted order
        word_list.flatten(1).sort_by(&:last).map(&:first)
      end

      # Add the DFs to our cache for this document
      #
      # @param [Document] doc the document to add
      # @return [void]
      def add_dfs(doc)
        doc.term_vectors.each do |word, hash|
          # Oddly enough, you'll get weird bogus values for words that don't
          # appear in your document back from Solr.  Not sure what's up with
          # that.
          next if hash[:df] <= 0

          key = case stemming
                when :stem
                  word.stem
                when :lemma
                  RLetters::Analysis::Lemmatizer.lemma(word).dup
                else
                  word
                end

          corpus_dfs[key] ||= hash[:df]
        end
      end
    end
  end
end
