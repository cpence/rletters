
module RLetters
  module Datasets
    # Add the results of a search to a dataset
    #
    # This class batches the results of a search query and adds them to a
    # dataset.
    class AddSearch
      # Initialize the adder
      #
      # @param [Dataset] dataset the dataset to add results to
      # @param [String] q the search query
      # @param [Array<String>] fq an array of facet queries
      # @param [String] def_type the search type
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one Integer parameter)
      def initialize(dataset, q, fq, def_type, progress = nil)
        @dataset = dataset
        @dataset_id = dataset.to_param
        @q = q
        @fq = fq
        @def_type = def_type

        @progress = progress

        @start = 0
      end

      # Add the results of the query to the dataset
      #
      # @return [void]
      def call
        # Add batches until we run out (FIXME: a more ruby way to do this?)
        while add_batch
        end

        # Clear the disabled attribute
        @dataset.disabled = false
        @dataset.save
      rescue StandardError
        # FIXME: This should probably be a finally block?
        # Don't leave an empty dataset around under any circumstances
        @dataset.destroy
        raise
      end

      private

      # Add another batch of documents to the dataset
      #
      # @api private
      # @return [Boolean] true if adding should continue
      def add_batch
        result = RLetters::Solr::Connection.search(next_query)
        return false if result.num_hits == 0

        # Call the progress function
        @total ||= result.num_hits
        @progress && @progress.call((@start.to_f / @total.to_f * 100).to_i)

        # Import the dataset entries (quickly)
        ::Datasets::Entry.import([:uid, :dataset_id],
                                 result.documents.map do |d|
                                   [d.uid, @dataset_id]
                                 end,
                                 validate: false)

        # Check to see if there's any externally fetched documents here
        unless @dataset.fetch
          if result.documents.any?(&:fulltext_url)
            @dataset.fetch = true
            @dataset.save
          end
        end

        # Tell the caller whether or not we should continue
        @start <= @total
      end

      # Get the next batched search query
      #
      # @api private
      # @return [Hash] parameters for the next Solr query we should run
      def next_query
        @start += 1000

        {
          start: @start - 1000,
          rows: 1000,
          q: @q,
          fq: @fq,
          def_type: @def_type,
          fl: 'uid,fulltext_url',
          facet: false
        }
      end
    end
  end
end
