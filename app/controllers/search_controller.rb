
# Search and browse the document database
#
# This controller displays both traditional and advanced search pages and the
# resulting lists of documents.
#
# @see RLetters::Solr::Connection.search
class SearchController < ApplicationController
  # Show the main search index page
  #
  # @return [void]
  def index
    # Get the documents
    query = RLetters::Solr::Search.params_to_query(params,
                                                   request.format != :html)
    @result = RLetters::Solr::Connection.search(query)
    @result_presenter = RLetters::Presenters::SearchResultPresenter.new(result: @result)

    # If this is an AJAX HTML request, render the results table rows only
    if request.format == :html && request.xhr?
      disable_browser_cache
      render :index_xhr, layout: false
    else
      render
    end
  end

  # Show the advanced search page
  #
  # @return [void]
  def advanced
    @search_fields = RLetters::Solr::Advanced.search_fields
  end
end
