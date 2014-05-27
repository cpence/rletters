# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Collocation
      class PartsOfSpeech < Base
        # No coverage here, as we don't install Stanford NLP on Travis
        # :nocov:

        def call
          # PoS + FREQUENCY
          # Take only those that match the following patterns:
          # A N, N N, A A N, A N N, N A N, N N N, N P N
          # sort by frequency
          fail ArgumentError, 'NLP library not available' unless NLP_ENABLED
          total = @dataset.entries.size

          # We actually aren't going to use Analysis::WordFrequency here; the
          # NLP POS tagger requires us to send it full sentences for maximum
          # accuracy.
          tagger = StanfordCoreNLP::MaxentTagger.new(POS_TAGGER_PATH)
          enum = RLetters::Datasets::DocumentEnumerator.new(@dataset,
                                                            fulltext: true)
          enum.each_with_index.each_with_object({}) { |(doc, i), result|
            @progress.call((i.to_f / total.to_f * 100.0).to_i) if @progress

            tagged = tagger.tagString(doc.fulltext).split

            tagged.each_cons(2).map do |t|
              if @word
                next unless t.any? { |w| w.start_with?("#{@word}_") }
              end

              bigram = t.join(' ')
              if POS_BI_REGEXES.any? { |r| bigram =~ r }
                stripped = bigram.gsub(/_(JJ[^\s]?|NN[^\s]{0,2}|IN)(\s+|\Z)/, '\2')

                result[stripped] ||= 0
                result[stripped] += 1
              end
            end

            tagged.each_cons(3).map do |t|
              if @word
                next unless t.any? { |w| w.start_with?("#{@word}_") }
              end

              trigram = t.join(' ')
              if POS_TRI_REGEXES.any? { |r| trigram =~ r }
                stripped = trigram.gsub(/_(JJ[^\s]?|NN[^\s]{0,2}|IN)(\s+|\Z)/, '\2')

                result[stripped] ||= 0
                result[stripped] += 1
              end
            end
          }.sort { |a, b| b[1] <=> a[1] }
        end

        private

        POS_BI_REGEXES = [
          /[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # ADJ NOUN
          /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/ # NOUN NOUN
        ]
        POS_TRI_REGEXES = [
          /[^\s]+_JJ[^\s]?\s+[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # ADJ ADJ NOUN
          /[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/, # ADJ NOUN NOUN
          /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # NOUN ADJ NOUN
          /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/, # NOUN NOUN NOUN
          /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_IN\s+[^\s]+_NN[^\s]{0,2}/ # NOUN PREP NOUN
        ]

        # :nocov:
      end
    end
  end
end
