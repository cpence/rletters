
module RLetters
  # Code for performing various analyses on document text
  module Analysis
    # Compute named entity references for a given dataset
    #
    # @!attribute dataset
    #   @return [Dataset] if set, the dataset to analyze (else the entire
    #     corpus)
    # @!attribute progress
    #   @return [Proc] if set, a function to call with percentage of completion
    #     (one integer parameter)
    class NamedEntities
      include Service
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :dataset, Dataset
      attribute :progress, Proc

      # Perform the NER analysis
      #
      # @return [Hash<String, Array<String>>] the extracted named entity
      #   references, or `nil` if the analysis cannot be run (NLP toolkit is
      #   unavailable).
      #
      #   As an example:
      #
      #   entity_references['ORGANIZATION'] = ['Harvard University',
      #                                        'Ivy League',
      #                                        'U.S. Supreme Court']
      #   entity_references['LOCATION'] = ['Virginia', 'U.S.']
      #   entity_references['PERSON'] = ['John Marshall', 'William III']
      def call
        return nil if ENV['NLP_TOOL_PATH'].blank?

        total = dataset.document_count
        text_cache = ''

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset: dataset,
                                                          fulltext: true)
        enum.each_with_index do |doc, i|
          progress && progress.call((i.to_f / total.to_f * 50.0).to_i)
          text_cache << doc.fulltext
        end

        ret = NLP.named_entities(text_cache)

        progress && progress.call(100)

        ret
      end
    end
  end
end
