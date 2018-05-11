# frozen_string_literal: true

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

          self.result = {}

          enum = Datasets::DocumentEnumerator.new(
            dataset: dataset,
            fl: 'uid'
          )
          total = dataset.document_count

          enum.each_with_index do |doc, i|
            progress&.call((i.to_f / total.to_f * 100).to_i)

            lister = Documents::WordList.new
            words = lister.words_for(doc.uid)

            tagged = Tagger.get_readable(words.join(' ')).split

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
          %r{[^\s]+/JJ[^\s]?\s+[^\s]+/NN[^\s]{0,2}}, # ADJ NOUN
          %r{[^\s]+/NN[^\s]{0,2}\s+[^\s]+/NN[^\s]{0,2}} # NOUN NOUN
        ].freeze

        # Regular expressions which match trigram part-of-speech patterns
        POS_TRI_REGEXES = [
          %r{[^\s]+/JJ[^\s]?\s+[^\s]+/JJ[^\s]?\s+[^\s]+/NN[^\s]{0,2}}, # ADJ ADJ NOUN
          %r{[^\s]+/JJ[^\s]?\s+[^\s]+/NN[^\s]{0,2}\s+[^\s]+/NN[^\s]{0,2}}, # ADJ NOUN NOUN
          %r{[^\s]+/NN[^\s]{0,2}\s+[^\s]+/JJ[^\s]?\s+[^\s]+/NN[^\s]{0,2}}, # NOUN ADJ NOUN
          %r{[^\s]+/NN[^\s]{0,2}\s+[^\s]+/NN[^\s]{0,2}\s+[^\s]+/NN[^\s]{0,2}}, # NOUN NOUN NOUN
          %r{[^\s]+/NN[^\s]{0,2}\s+[^\s]+/IN\s+[^\s]+/NN[^\s]{0,2}} # NOUN PREP NOUN
        ].freeze

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
            if focal_word && t.none? { |w| w.start_with?("#{focal_word.downcase}/") }
              next
            end

            gram = t.join(' ')
            next unless regexes.any? { |r| gram =~ r }

            stripped = gram.gsub(%r{/(JJ[^\s]?|NN[^\s]{0,2}|IN)(\s+|\Z)}, '\2')

            result[stripped] ||= 0
            result[stripped] += 1
          end
        end
      end
    end
  end
end
