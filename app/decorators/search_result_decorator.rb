
# Decorate a search result object
#
# This adds methods to access the documents and facets returned as part of
# a search, as well as unified ways to deal with the facets and categories
# (together, called "filters") that users may utilize.
class SearchResultDecorator < ApplicationDecorator
  decorates RLetters::Solr::SearchResult
  delegate_all

  # Decorate the documents
  #
  # @return [Array<DocumentDecorator] the decorated documents
  def documents
    return nil unless object.documents
    DocumentDecorator.decorate_collection(object.documents)
  end

  # Decorate the facets
  #
  # @return [FacetsDecorator] the decorated facets
  def facets
    return nil unless object.facets
    FacetsDecorator.decorate(object.facets)
  end

  # Decorate the complete set of categories
  #
  # @return [CategoriesDecorator] all categories, decorated
  def categories
    return nil unless Documents::Category.count > 0
    CategoriesDecorator.decorate(Documents::Category.all)
  end

  # Decorate the active categories
  #
  # @return [CategoriesDecorator] the decorated categories
  def active_categories
    cats = [h.params[:categories] || []].flatten.map do |id|
      Documents::Category.find(id)
    end

    CategoriesDecorator.decorate(cats)
  end

  # Return the path to the next page of search results
  #
  # @return [String] path to next page of search results
  def next_page_path
    return nil if solr_response['nextCursorMark'] == h.params[:cursor_mark]

    new_params = h.params.deep_dup.except!(:cursor_mark)
    new_params[:cursor_mark] = solr_response['nextCursorMark']

    h.search_path(new_params.symbolize_keys)
  end

  # Return a list of links to remove all active filters
  #
  # @return [String] removal links for all filters
  def filter_removal_links
    return '' if h.params[:fq].blank? && active_categories.blank?

    ''.html_safe.tap do |ret|
      # Header
      ret << h.content_tag(:li,
                           h.content_tag(
                             :strong,
                             I18n.t('search.index.active_filters')),
                           class: 'filter-header')

      # Remove all
      new_params = h.params.deep_dup.except!(:categories, :fq)
      ret << h.content_tag(
        :li,
        h.link_to(h.html_escape(I18n.t('search.index.remove_all')) +
                                close_icon,
                  h.search_path(new_params.symbolize_keys)))

      # Categories and facets
      ret << active_categories.removal_links unless active_categories.blank?
      ret << facets.removal_links unless facets.blank?
    end
  end

  # Return a formatted version of the number of hits for the last search
  #
  # @return [String] number of hits for the search
  def num_hits
    if object.params[:q]&.!=('*:*') || object.params[:fq]
      I18n.t 'search.index.num_hits_found', count: object.num_hits
    else
      I18n.t 'search.index.num_documents_database', count: object.num_hits
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
  def sort
    sort_string_for object.params['sort']
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
    return I18n.t('search.index.sort_unknown') unless SORT_METHODS.include?(method)

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
