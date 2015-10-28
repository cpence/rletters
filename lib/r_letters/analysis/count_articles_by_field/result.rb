
module RLetters
  module Analysis
    class CountArticlesByField
      # A class encapsulating the results from an analysis
      #
      # @!attribute counts
      #   @return [Hash<String, Numeric>] the mapping of field values to counts
      # @!attribute normalize
      #   @return [Boolean] whether or not the counts were normalized
      # @!attribute normalization_dataset
      #   @return [Dataset] the dataset that was used for normalization
      class Result
        include Virtus.model(strict: true, required: false,
                             nullify_blank: true)

        attribute :counts, Hash[String => Numeric]
        attribute :normalize, Boolean
        attribute :normalization_dataset, Dataset
      end
    end
  end
end
