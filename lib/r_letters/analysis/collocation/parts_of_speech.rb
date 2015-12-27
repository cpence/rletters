
module RLetters
  module Analysis
    module Collocation
      # Analyze collocations by selecting part-of-speech patterns
      #
      # @!attribute result
      #   @return [Hash] the result currently being constructed
      class PartsOfSpeech < Base
        attribute :result, Hash, reader: :private, writer: :private

        # Perform parts-of-speech analysis
        #
        # This analyzer overrides the call method, as its main loop is entirely
        # different from that of the other collocation scanners.
        #
        # We select the following patterns of parts of speech, when those
        # appear:
        #
        # - Adjective Noun
        # - Noun Noun
        # - Adjective Adjective Noun
        # - Adjective Noun Noun
        # - Noun Adjective Noun
        # - Noun Noun Noun
        # - Noun Preposition Noun
        #
        # Then, we sort by frequency of occurrence and take the top matches.
        #
        # @return [RLetters::Analysis::Collocation::Result] analysis results
        def call
          # Ignore num_pairs if we want all of the cooccurrences
          self.num_pairs = nil if all || num_pairs&.<=(0)

          total = dataset.document_count

          # We actually aren't going to use Analysis::WordFrequency here; the
          # NLP POS tagger requires us to send it full sentences for maximum
          # accuracy.
          enum = RLetters::Datasets::DocumentEnumerator.new(dataset: dataset,
                                                            fulltext: true)

          self.result = {}
          enum.each_with_index do |doc, i|
            progress&.call((i.to_f / total.to_f * 100).to_i)

            tagged = NLP.parts_of_speech(doc.fulltext.mb_chars.downcase.to_s)

            search_for_regexes(tagged, 2, POS_BI_REGEXES)
            search_for_regexes(tagged, 3, POS_TRI_REGEXES)
          end

          progress&.call(100)

          self.result = result.sort { |a, b| b[1] <=> a[1] }
          self.result = result.take(num_pairs) if num_pairs

          Result.new(scoring: :parts_of_speech, collocations: result.to_a)
        end

        private

        # Regular expressions which match bigram part-of-speech patterns
        POS_BI_REGEXES = [
          /[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # ADJ NOUN
          /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/ # NOUN NOUN
        ]

        # Regular expressions which match trigram part-of-speech patterns
        POS_TRI_REGEXES = [
          /[^\s]+_JJ[^\s]?\s+[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # ADJ ADJ NOUN
          /[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/, # ADJ NOUN NOUN
          /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # NOUN ADJ NOUN
          /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/, # NOUN NOUN NOUN
          /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_IN\s+[^\s]+_NN[^\s]{0,2}/ # NOUN PREP NOUN
        ]

        # Search for regexes of a given number of words
        #
        # This function detects collocations which match the given array of
        # regular expressions, and saves the results in the +@result+ hash.
        #
        # @param [Array<String>] tagged_words The words, tagged by the NL
        #   parts of speech tagger
        # @param [Integer] size The size of n-grams to be detected by these
        #   regular expressions
        # @param [Array<Regexp>] regexes The array of regexes to match
        # @return [void]
        def search_for_regexes(tagged_words, size, regexes)
          tagged_words.each_cons(size).map do |t|
            if focal_word && !t.any? { |w| w.start_with?("#{focal_word}_") }
              next
            end

            gram = t.join(' ')
            next unless regexes.any? { |r| gram =~ r }

            stripped = gram.gsub(/_(JJ[^\s]?|NN[^\s]{0,2}|IN)(\s+|\Z)/, '\2')

            result[stripped] ||= 0
            result[stripped] += 1
          end
        end
      end
    end
  end
end
