
module RLetters
  # Code for performing various analyses on document text
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
      # @param [Dataset] dataset The dataset to analyze
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      def initialize(dataset, progress = nil)
        @dataset = dataset
        @progress = progress
      end

      # Perform the NER analysis
      #
      # This function fills out the +entity_references+ attribute.
      #
      # @return [void]
      def call
        return if ENV['NLP_TOOL_PATH'].blank?

        total = @dataset.entries.size
        text_cache = ''

        enum = RLetters::Datasets::DocumentEnumerator.new(@dataset,
                                                          fulltext: true)
        enum.each_with_index do |doc, i|
          @progress && @progress.call((i.to_f / total.to_f * 50.0).to_i)

          text_cache += doc.fulltext
        end

        @entity_references = NLP.named_entities(text_cache)

        @progress && @progress.call(100)
      end
    end
  end
end
