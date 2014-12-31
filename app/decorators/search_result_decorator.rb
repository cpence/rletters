
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

  # Return a list of links to remove all active filters
  #
  # @return [String] removal links for all filters
  def filter_removal_links
    if h.params[:fq].blank? && active_categories.blank?
      return h.link_to(I18n.t('search.index.no_filters'), '#',
                       class: 'btn navbar-btn btn-default disabled')
    end

    ''.html_safe.tap do |ret|
      # Remove all
      new_params = h.params.deep_dup.except!(:categories, :fq)
      ret << h.link_to(h.search_path(new_params.symbolize_keys),
                       class: 'btn navbar-btn btn-primary') do
        h.html_escape(I18n.t('search.index.remove_all')) + close_icon
      end

      # Categories and facets
      ret << active_categories.removal_links unless active_categories.blank?
      ret << facets.removal_links unless facets.blank?
    end
  end

  # Return a formatted version of the number of hits for the last search
  #
  # @return [String] number of hits for the search
  def num_hits
    if (object.params[:q] && object.params[:q] != '*:*') || object.params[:fq]
      I18n.t 'search.index.num_hits_found', count: object.num_hits
    else
      I18n.t 'search.index.num_documents_database', count: object.num_hits
    end
  end

  # Render the pagination links
  #
  # @return [String] full set of pagination links for the current page
  def pagination
    # Extract page and per_page from the Solr query that we called
    per_page = (object.params['rows'] || 10).to_i
    start = (object.params['start'] || 0).to_i
    page = start / per_page

    num_pages = object.num_hits.to_f / per_page.to_f
    num_pages = Integer(num_pages.ceil)
    return ''.html_safe if num_pages <= 1

    content = page_link('&laquo;'.html_safe,
                        page == 0 ? nil : page - 1,
                        page == 0 ? 'unavailable' : nil)

    # Render at most seven pagination links
    if num_pages < 7
      range_to_render = (0..num_pages).to_a
    elsif page < 3
      range_to_render = [0, 1, 2, 3, nil, num_pages - 2, num_pages - 1]
    elsif page >= num_pages - 3
      range_to_render = [0, 1, nil, num_pages - 4, num_pages - 3,
                         num_pages - 2, num_pages - 1]
    else
      range_to_render = [0, nil, page - 1, page, page + 1, nil,
                         num_pages - 1]
    end

    range_to_render.each do |p|
      if p.nil?
        content << page_link('&hellip;'.html_safe, nil, 'unavailable')
      else
        content << page_link((p + 1).to_s, p, page == p ? 'current' : nil)
      end
    end

    content << page_link('&raquo;'.html_safe,
                         page == num_pages - 1 ? nil : page + 1,
                         page == num_pages - 1 ? 'unavailable' : nil)

    content
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

  # Make a link to a page for the pagination widget
  #
  # @param [String] text text for this link
  # @param [Integer] num the page number (0-based)
  # @param [String] klass class to put on the <li> tag
  # @return [String] the requested link
  def page_link(text, num, klass)
    if num.nil?
      href = '#'
    else
      new_params = h.params.deep_dup
      if num == 0
        new_params.delete :page
      else
        new_params[:page] = num
      end
      href = h.search_path(new_params.symbolize_keys)
    end

    h.content_tag(:li, h.link_to(text, href), class: klass)
  end

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
