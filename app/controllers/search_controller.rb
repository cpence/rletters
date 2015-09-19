
# Search and browse the document database
#
# This controller displays both traditional and advanced search pages and the
# resulting lists of documents.  Its main function is to convert the
# user's provided search criteria into Solr queries for
# `RLetters::Solr::Connection.search`.
#
# @see RLetters::Solr::Connection.search
class SearchController < ApplicationController
  decorates_assigned :result, with: SearchResultDecorator

  # Show the main search index page
  #
  # The controller just passes the search parameters through
  # `search_params_to_solr_query`, then sends this solr query on to the
  # server using `RLetters::Solr::Connection.search`.
  #
  # @return [void]
  def index
    page = params[:page].to_i.lbound(0)
    per_page = (current_user.try(:per_page) ||
                params[:per_page].try(:to_i) || 10).bound(10, 100)

    # Default sort to relevance if there's a search, otherwise year
    if params[:advanced] || params[:q]
      sort = 'score desc'
    else
      sort = 'year_sort desc'
    end
    sort = params[:sort] if params[:sort]

    solr_query = search_params_to_solr_query(params)
    solr_query[:sort] = sort
    solr_query[:start] = page * per_page
    solr_query[:rows] = per_page

    # Get the documents
    @result = RLetters::Solr::Connection.search(solr_query)
  end

  # Show the advanced search page
  #
  # @return [void]
  def advanced
    @search_fields = RLetters::Solr::Advanced.search_fields
  end

  private

  # Convert from search parameters to Solr query parameters
  #
  # This function takes the GET parameters passed in to the search and
  # handles converting them to the query format expected by Solr.  Primarily,
  # it is intended to support the advanced search page.
  #
  # @param [Hash] params the Rails params object
  # @return [Hash] Solr-format query parameters
  def search_params_to_solr_query(params)
    # Remove any blank values (you get these on form submissions, for
    # example)
    params.delete_if { |_, v| v.blank? }

    # Initialize by copying over the faceted-browsing query
    query_params = {}
    query_params[:fq] = params[:fq] unless params[:fq].nil?

    # And converting categories to facets
    if params[:categories]
      category_journals = params[:categories].collect do |id|
        Documents::Category.find(id).journals.map { |j| "\"#{j}\"" }
      end
      category_journals.uniq!

      query_params[:fq] ||= []
      query_params[:fq] << "journal_facet:(#{category_journals.join(' OR ')})"
    end

    # Advanced search support happens here
    if params[:advanced]
      q_array = []

      # Advanced search, step through the fields
      query_params[:def_type] = 'lucene'

      # Copy the basic query across
      q_array << "#{params[:q]} AND " if params[:q].present?

      # Hard-coded limit of 100 on the number of advanced queries
      0.upto(100) do |i|
        field = params["field_#{i}".to_sym]
        value = params["value_#{i}".to_sym]
        boolean = params["boolean_#{i}".to_sym]
        break if field.nil? || value.nil?

        q_array << RLetters::Solr::Advanced.query_for(field, value, boolean)
      end

      # Prune any empty/nil (invalid) queries
      q_array.delete_if(&:blank?)

      # If there's no query after that, add the all-documents operator
      if q_array.empty?
        query_params[:q] = '*:*'
      else
        # Remove the last trailing boolean connective
        query_params[:q] = q_array.join.chomp(' OR ').chomp(' AND ')
      end
    else
      # Simple search
      if params[:q]
        query_params[:q] = params[:q]
        query_params[:def_type] = 'dismax'
      else
        query_params[:q] = '*:*'
        query_params[:def_type] = 'lucene'
      end
    end

    query_params
  end
end
