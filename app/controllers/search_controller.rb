# -*- encoding : utf-8 -*-

# Search and browse the document database
#
# This controller displays both traditional and advanced search pages and the
# resulting lists of documents.  Its main function is to convert the
# user's provided search criteria into Solr queries for
# +RLetters::Solr::Connection.search+.
class SearchController < ApplicationController
  decorates_assigned :result, with: SearchResultDecorator

  # Show the main search index page
  #
  # The controller just passes the search parameters through
  # +search_params_to_solr_query+, then sends this solr query on to the
  # server using +RLetters::Solr::Connection.search+.
  #
  # @api public
  # @return [undefined]
  def index
    page = params[:page].to_i.lbound(0)
    per_page = (current_user.try(:per_page) ||
                params[:per_page].try(:to_i) || 10).bound(10, 100)

    # Default sort to relevance if there's a search, otherwise year
    if params[:precise] || params[:q]
      sort = 'score desc'
    else
      sort = 'year_sort desc'
    end
    sort = params[:sort] if params[:sort]

    solr_query = search_params_to_solr_query(params)
    solr_query.merge!(sort: sort,
                      start: page * per_page,
                      rows: per_page)

    # Get the documents
    @result = RLetters::Solr::Connection.search(solr_query)
    @facets = @result.facets
    @documents = @result.documents
  end

  # Show the advanced search page
  #
  # @api public
  # @return [undefined]
  def advanced; end

  private

  # Convert from search parameters to Solr query parameters
  #
  # This function takes the GET parameters passed in to the search and
  # handles converting them to the query format expected by Solr.  Primarily,
  # it is intended to support the advanced search page.
  #
  # @api private
  # @param [Hash] params the Rails params object
  # @return [Hash] Solr-format query parameters
  # @example Convert an advanced search to Solr format
  #   search_params_to_solr_query({ precise: 'true', title: 'test' })
  #   # => { :def_type => 'lucene', :q => 'title:(test)' }
  def search_params_to_solr_query(params)
    # Remove any blank values (you get these on form submissions, for
    # example)
    params.delete_if { |k, v| v.blank? }

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

    if params[:precise]
      q_array = []

      # Advanced search, step through the fields
      query_params[:def_type] = 'lucene'
      q_array << "#{params[:q]}" if params[:q].present?

      # Verbatim search fields
      %W(volume number pages).each do |f|
        q_array << "#{f}:\"#{params[f.to_sym]}\"" if params[f.to_sym].present?
      end

      # Verbatim or fuzzy search fields
      %W(title journal).each do |f|
        if params[f.to_sym].present?
          field = f

          param = params[(f + '_type').to_sym]
          field += '_stem' if param && param == 'fuzzy'

          q_array << "#{field}:\"#{params[f.to_sym]}\""
        end
      end

      # Fulltext is different, because of fulltext_search
      if params[:fulltext].present?
        if params[:fulltext_type] && params[:fulltext_type] == 'fuzzy'
          field = 'fulltext_stem'
        else
          field = 'fulltext_search'
        end
        q_array << "#{field}:\"#{params[:fulltext]}\""
      end

      # Handle the authors separately, for splitting support (authors search
      # is an AND search, not an OR search)
      if params[:authors].present?
        authors = params[:authors].split(',').map do |a|
          RLetters::Documents::Author.new(a.strip).to_lucene
        end
        authors_str = authors.join(' AND ')

        q_array << "authors:(#{authors_str})"
      end

      # Handle the year separately, for range support
      if params[:year_ranges].present?
        # Strip whitespace, split on commas
        ranges = params[:year_ranges].gsub(/\s/, '').split(',')
        year_queries = []

        ranges.each do |r|
          if r.include? '-'
            range_years = r.split('-')
            next unless range_years.size == 2
            next if range_years[0].match(/\A\d+\z/).nil?
            next if range_years[1].match(/\A\d+\z/).nil?

            year_queries << "[#{range_years[0]} TO #{range_years[1]}]"
          else
            next if r.match(/\A\d+\z/).nil?

            year_queries << r
          end
        end

        unless year_queries.empty?
          q_array << "year:(#{year_queries.join(" OR ")})"
        end
      end

      # If there's no query after that, add the all-documents operator
      if q_array.empty?
        query_params[:q] = '*:*'
      else
        query_params[:q] = q_array.join(' AND ')
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
