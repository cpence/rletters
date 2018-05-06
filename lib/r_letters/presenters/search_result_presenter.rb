# frozen_string_literal: true

module RLetters
  module Presenters
    # Code for formatting attributes of a SearchResult object
    class SearchResultPresenter
      include Virtus.model(strict: true, required: true)
      attribute :result, Solr::SearchResult

      # Return the path to the next page of search results
      #
      # @param [ActionController::Parameters] params search parameters for this
      #   request
      # @return [ActionController::Parameters] parameters to search page for
      #   the next page of results (or nil, if on the last page)
      def next_page_params(params)
        if result.solr_response['nextCursorMark'] == params[:cursor_mark]
          return nil
        end

        ret = params.except(:cursor_mark)
        ret[:cursor_mark] = result.solr_response['nextCursorMark']

        RLetters::Solr::Search::permit_params(ret)
      end

      # Return a formatted version of the number of hits for the last search
      #
      # @return [String] number of hits for the search
      def num_hits_string
        if result.params[:q]&.!=('*:*') || result.params[:fq]
          I18n.t 'search.index.num_hits_found', count: result.num_hits
        else
          I18n.t 'search.index.num_documents_database', count: result.num_hits
        end
      end

      # Return an array of all sort methods
      #
      # @return [Array<String>] all possible sorting strings
      def sort_methods
        SORT_METHODS.map { |m| [m, sort_string_for(m)] }
      end

      # Get the current sort method as a string
      #
      # @return [String] user-friendly representation of current sort method
      def current_sort_method
        sort_string_for result.params['sort']
      end

      private

      # The array of all sort methods
      SORT_METHODS = [
        'score desc',
        'authors_sort asc',
        'authors_sort desc',
        'title_sort asc',
        'title_sort desc',
        'journal_sort asc',
        'journal_sort desc',
        'year_sort asc',
        'year_sort desc'
      ]

      # Convert a precise sort method into a friendly string
      #
      # This function converts a sort method ('relevance', 'title', 'author',
      # 'journal', 'year') and sort direction ('asc' or 'desc') into a
      # user-friendly string.
      #
      # @param [String] method the sort method
      # @return [String] user-friendly representation of sort method
      def sort_string_for(method)
        unless SORT_METHODS.include?(method)
          return I18n.t('search.index.sort_unknown')
        end

        parts = method.split(' ')
        method = parts[0]
        dir = I18n.t("search.index.sort_#{parts[1]}")

        method_spec = case method
                      when 'score'
                        I18n.t('search.index.sort_score')
                      when 'title_sort'
                        "#{Document.human_attribute_name('title')} #{dir}"
                      when 'authors_sort'
                        "#{Document.human_attribute_name('authors')} #{dir}"
                      when 'journal_sort'
                        "#{Document.human_attribute_name('journal')} #{dir}"
                      when 'year_sort'
                        "#{Document.human_attribute_name('year')} #{dir}"
                      end

        "#{I18n.t('search.index.sort_prefix')} #{method_spec}"
      end
    end
  end
end
