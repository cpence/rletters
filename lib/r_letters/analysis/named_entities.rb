# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    # Compute named entity references for a given dataset
    #
    # @!attribute [r] entity_references
    #   @return [Hash<String, Array<String>>] The extracted named entity references
    #
    #   This attribute's format is a hash that looks like this, mapping from the
    #   kind of entity to a list of entities located:
    #
    #   entity_references['ORGANIZATION'] = ['Harvard University',
    #                                        'Ivy League',
    #                                        'U.S. Supreme Court']
    #   entity_references['LOCATION'] = ['Virginia', 'U.S.']
    #   entity_references['PERSON'] = ['John Marshall', 'William III']
    class NamedEntities
      attr_reader :entity_references

      # Create a new NER analyzer and analyze
      #
      # @api public
      # @param [Dataset] dataset The dataset to analyze
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      def initialize(dataset, progress = nil)
        return unless NLP_ENABLED

        classifier = StanfordCoreNLP::CRFClassifier.getClassifierNoExceptions(NER_CLASSIFIER_PATH)
        @entity_references = {}
        total = dataset.entries.size

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset, fulltext: true)
        enum.each_with_index do |doc, i|
          progress.call((i.to_f / total.to_f * 100.0).to_i) if progress

          triples = classifier.classifyToCharacterOffsets(doc.fulltext)
          triples.each do |t|
            s = Integer(t.second.to_s)
            e = Integer(t.third.to_s)
            range = s...e

            type = t.first.to_s
            result = doc.fulltext[range]

            @entity_references[type] ||= []
            @entity_references[type] << result
          end
        end

        progress.call(100) if progress
      end
    end
  end
end
