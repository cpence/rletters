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
      # @option options [Integer] :ngrams If set, return ngrams rather than
      #   single words.  Can be set to any integer >= 1.  Defaults to 1.
      # @option options [Symbol] :stemming If set to +:stem+, pass the words
      #   through a Porter stemmer before returning them.  If set to +:lemma+,
      #   pass them through the Stanford NLP lemmatizer, if available.  The
      #   NLP lemmatizer is much slower, as it requires accessing the fulltext
      #   of the document rather than reconstructing from the term vectors.
      #   Defaults to no stemming.
      def initialize(options = {})
        @options = options.compact.reverse_merge(ngrams: 1, stemming: nil)

        @options[:ngrams] = [@options[:ngrams], 1].max
        unless [:stem, :lemma].include?(options[:stemming])
          @options[:stemming] = nil
        end

        @dfs = {}
      end

      # Reset to initial state in the word lister
      #
      # @return [undefined]
      # @example Reset this word lister
      #   word_list.reset!
      def reset!
        @dfs = {}
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
        word_list = if @options[:stemming] == :lemma &&
                       Admin::Setting.nlp_tool_path.present?
                      get_lemmatized_words(uid)
                    else
                      get_words(uid, @options[:stemming] == :stem)
                    end

        return word_list if !@options[:ngrams] || @options[:ngrams] <= 1
        word_list.each_cons(@options[:ngrams]).map { |a| a.join(' ') }
      end

      # The document frequency of each of the words in the corpus
      #
      # This function returns a hash where the keys are the words in the
      # document and the values are the document frequencies in the entire
      # corpus (the number of documents in the corpus in which the word
      # appears).
      #
      # Note that this will only return values for words appearing in the
      # documents that have been scanned by +words_for+ since this word lister
      # was created.
      #
      # @return [Hash<String, Integer>] the document frequencies for each word
      # @example Get the number of documents in which a given word appears
      #   RLetters::Documents::WordList
      def corpus_dfs
        stem_dfs
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
        add_dfs(doc)

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
      # @param [String] uid the document to get lemmatized words for
      # @return [Array<String>] list of lemmatized words for document
      def get_lemmatized_words(uid)
        doc = Document.find(uid, fulltext: true, term_vectors: true)
        add_dfs(doc)

        Analysis::NLP.lemmatize_words(doc.fulltext.split)
      end

      # Add the DFs to our cache for this document
      #
      # @api private
      # @param [Document] doc the document to add
      # @return [void]
      def add_dfs(doc)
        doc.term_vectors.each do |word, hash|
          next if @dfs.include?(word)

          # Oddly enough, you'll get weird bogus values for words that don't
          # appear in your document back from Solr.  Not sure what's up with
          # that.
          if hash[:df] > 0
            @dfs[word] = hash[:df]
          end
        end
      end

      # Stem or lemmatize the DFs if required
      #
      # @api private
      # @return [Hash<String, Integer>] the dfs, stemmed or lemmatized if
      #   required
      def stem_dfs
        case @options[:stemming]
        when :stem
          {}.tap do |ret|
            @dfs.each do |k, v|
              stem = k.stem
              ret[stem] ||= 0
              ret[stem] += v
            end
          end
        when :lemma
          # This may not work without sentential context to feed to the NLP
          # engine, but it's better than not trying anything at all
          {}.tap do |ret|
            @dfs.each do |k, v|
              lemma = Analysis::NLP.lemmatize_words(k)[0]

              ret[lemma] ||= 0
              ret[lemma] += v
            end
          end
        else
          @dfs
        end
      end
    end
  end
end
