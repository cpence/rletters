# -*- encoding : utf-8 -*-
# No test coverage here, as we aren't installing the Stanford NLP package on
# Travis.
# :nocov:

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
class NERAnalyzer
  attr_reader :entity_references

  # Create a new NER analyzer and analyze
  #
  # @api public
  # @param [Dataset] dataset The dataset to analyze
  def initialize(dataset)
    return unless NLP_ENABLED

    classifier = StanfordCoreNLP::CRFClassifier.getClassifierNoExceptions(NER_CLASSIFIER_PATH)
    @entity_references = {}

    dataset.entries.each do |e|
      doc = Document.find(e.uid, fulltext: true)
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
  end
end
