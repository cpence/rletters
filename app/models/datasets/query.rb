
module Datasets
  # A search query used to construct a dataset
  #
  # We represent the content of datasets by saving the searches that were used
  # by the user to create that dataset.
  #
  # @!attribute dataset
  #   @return [Dataset] the dataset this query belongs to
  # @!attribute q
  #   @return [String] the query used in this search
  # @!attribute fq
  #   @return [Array<String>] the faceted query parameters used in this search
  # @!attribute def_type
  #   @return [String] the search type used in this search
  class Query < ActiveRecord::Base
    self.table_name = 'datasets_queries'
    serialize :fq, Array
    validates :def_type, presence: true

    # Do *not* validate the dataset association here.  Since datasets and
    # their associated queries are always created at the same time, the
    # validation will fail, as the dataset hasn't yet been saved.

    belongs_to :dataset

    # Return the result of doing this query, with additional parameters added
    #
    # @return [RLetters::Solr::SearchResult] the search results
    def search(params = {})
      RLetters::Solr::Connection.search(params.merge(q: q,
                                                     fq: fq,
                                                     def_type: def_type))
    end

    # Return the number of documents this query matches
    #
    # @return [Integer] the number of documents this query returns
    def size
      search(rows: 0).num_hits
    end

    # Update the cached number of documents in the Dataset model
    #
    # @return [void]
    def update_size_cache
      dataset.queries.reload
      dataset.document_count = dataset.queries.map { |q| q.size }.inject(:+)
      dataset.save
    end

    after_save :update_size_cache
    after_destroy :update_size_cache
  end
end
