# frozen_string_literal: true

module RLetters
  # Code for performing various analyses on document text
  module Analysis
    # Compute proper name references for a given dataset
    #
    # @!attribute dataset
    #   @return [Dataset] if set, the dataset to analyze (else the entire
    #     corpus)
    # @!attribute progress
    #   @return [Proc] if set, a function to call with percentage of completion
    #     (one integer parameter)
    class ProperNames
      include Service
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :dataset, Dataset
      attribute :progress, Proc

      # Perform the proper name analysis
      #
      # @return [Hash<String, Integer>] the list of proper names extracted,
      #   with frequency counts
      def call
        total = dataset.document_count
        ret = {}

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset: dataset,
                                                          fulltext: true)
        enum.each_with_index do |doc, i|
          progress&.call((i.to_f / total.to_f * 100).to_i)

          lister = Documents::WordList.new
          words = lister.words_for(doc.uid)

          tagged = Tagger.add_tags(words.join(' '))
          ret.merge!(Tagger.get_nouns(tagged)) { |_, v1, v2| v1 + v2 }
        end

        progress&.call(100)
        ret.sort_by { |(_, v)| -v }
      end
    end
  end
end
