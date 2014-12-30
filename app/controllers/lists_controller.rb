
# Access lists of authors and journals
#
# This controller returns JSON-formatted lists of authors and journals, for
# use in automated queries (such as autocomplete on the advanced search page).
class ListsController < ApplicationController
  # Build a list of authors
  #
  # @api [public]
  # @return [void]
  def authors
    @list = list_for(:authors, :authors_facet)
    render template: 'lists/list'
  end

  # Build a list of journals
  #
  # @api [public]
  # @return [void]
  def journals
    @list = list_for(:journal, :journal_facet)
    render template: 'lists/list'
  end

  private

  # Return the list of values for this field
  #
  # We search one field and facet on another, so we have to pass both here.
  #
  # @api private
  # @param [String] search_field the field to search the partial query on
  # @param [String] facet_field the field to return faceted results from
  # @return [Array<String>] the list of results
  def list_for(search_field, facet_field)
    result = solr_query_for(search_field, params[:q])

    return [] if !result.facets
    facets = result.facets.for_field(facet_field)
    return [] if !facets

    available_facets = facets.map do |f|
      f.hits > 0 ? f.value : nil
    end
    available_facets.compact
  end

  # Get the Solr query for a partial search for the given filter
  #
  # @api private
  # @param [String] field the field to search on
  # @param [String] filter the partial query to search for
  # @return [Hash] the Solr query parameters
  def solr_query_for(field, filter)
    if filter
      query = "#{field}:*#{filter}*"
    else
      query = '*:*'
    end

    RLetters::Solr::Connection.search({
      q: query,
      def_type: 'lucene',
      rows: 1
    })
  end
end
