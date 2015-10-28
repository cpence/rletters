
module RLetters
  module Datasets
    # Add the results of a search to a dataset
    #
    # This class batches the results of a search query and adds them to a
    # dataset.
    #
    # @!attribute dataset
    #   @return [Dataset] the dataset to add results to
    # @!attribute q
    #   @return [String] the search query
    # @!attribute fq
    #   @return [Array<String>] an array of facet queries
    # @!attribute def_type
    #   @return [String] the search type
    # @!attribute progress
    #   @return [Proc] If set, a function to call with a percentage of
    #     completion (one Integer parameter)
    class AddSearch
      include Service
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :dataset, Dataset, required: true
      attribute :q, String
      attribute :fq, Array[String]
      attribute :def_type, String, required: true
      attribute :progress, Proc

      attribute :start, Integer, default: 0,
                reader: :private, writer: :private
      attribute :total, Integer, reader: :private, writer: :private

      # Add the results of the query to the dataset
      #
      # @return [void]
      def call
        # Add batches until we run out (FIXME: a more ruby way to do this?)
        while add_batch
        end

        # Clear the disabled attribute
        dataset.disabled = false
        dataset.save
      rescue StandardError
        # FIXME: This should probably be a finally block?
        # Don't leave an empty dataset around under any circumstances
        dataset.destroy
        raise
      end

      private

      # Add another batch of documents to the dataset
      #
      # @return [Boolean] true if adding should continue
      def add_batch
        result = RLetters::Solr::Connection.search(next_query)
        return false if result.num_hits == 0

        # Call the progress function
        self.total ||= result.num_hits
        progress && progress.call((start.to_f / total.to_f * 100).to_i)

        # Import the dataset entries (quickly)
        ::Datasets::Entry.import([:uid, :dataset_id],
                                 result.documents.map do |d|
                                   [d.uid, dataset.to_param]
                                 end,
                                 validate: false)

        # Check to see if there's any externally fetched documents here
        unless dataset.fetch
          if result.documents.any?(&:fulltext_url)
            dataset.fetch = true
            dataset.save
          end
        end

        # Tell the caller whether or not we should continue
        start <= total
      end

      # Get the next batched search query
      #
      # @return [Hash] parameters for the next Solr query we should run
      def next_query
        self.start += 1000

        {
          start: start - 1000,
          rows: 1000,
          q: q,
          fq: fq,
          def_type: def_type,
          fl: 'uid,fulltext_url',
          facet: false
        }
      end
    end
  end
end
