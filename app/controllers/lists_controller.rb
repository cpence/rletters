
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
    result = solr_query_for(:authors, params[:q])
    available_facets = result.facets.for_field(:authors_facet).map do |f|
      f.hits > 0 ? f.value : nil
    end
    @list = available_facets.compact

    render template: 'lists/list'
  end

  # Build a list of journals
  #
  # @api [public]
  # @return [void]
  def journals
    result = solr_query_for(:journal, params[:q])
    available_facets = result.facets.for_field(:journal_facet).map do |f|
      f.hits > 0 ? f.value : nil
    end
    @list = available_facets.compact

    render template: 'lists/list'
  end

  private

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
