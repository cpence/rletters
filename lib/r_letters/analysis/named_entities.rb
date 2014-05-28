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
        return if Admin::Setting.nlp_tool_path.blank?

        total = dataset.entries.size
        text_cache = ""

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset, fulltext: true)
        enum.each_with_index do |doc, i|
          progress.call((i.to_f / total.to_f * 50.0).to_i) if progress

          text_cache += doc.fulltext
        end

        yml = Cheetah.run(Admin::Setting.nlp_tool_path, '-n',
                          stdin: text_cache, stdout: :capture)
        @entity_references = YAML.load(yml)

        progress.call(100) if progress
      end
    end
  end
end
