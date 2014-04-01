# -*- encoding : utf-8 -*-

class SearchResultDecorator < Draper::Decorator
  decorates RLetters::Solr::SearchResult
  delegate_all

  # Decorate the documents
  #
  # @api public
  # @return [Array<DocumentDecorator] the decorated documents
  # @example Iterate the decorated documents
  #   - result.documents.each { |f| ... }
  def documents
    DocumentDecorator.decorate_collection(object.documents)
  end

  # Decorate the facets
  #
  # @api public
  # @return [FacetsDecorator] the decorated facets
  # @example Iterate the decorated facets
  #   - result.facets.each { |f| ... }
  def facets
    FacetsDecorator.decorate(object.facets)
  end

  # Decorate the complete set of categories
  #
  # @api public
  # @return [CategoriesDecorator] all categories, decorated
  # @example Iterate through all the categories
  #   - result.categories.each { |c| ... }
  def categories
    CategoriesDecorator.decorate(Documents::Category.all)
  end

  # Decorate the active categories
  #
  # @api public
  # @return [CategoriesDecorator] the decorated categories
  # @example Iterate the active categories
  #   - result.active_categories.each { |c| ... }
  def active_categories
    cats = [h.params[:categories] || []].flatten.map do |id|
      Documents::Category.find(id)
    end

    CategoriesDecorator.decorate(cats)
  end

  # Return a list of links to remove all active filters
  #
  # @api public
  # @return [String] removal links for all filters
  def filter_removal_links
    if h.params[:fq].blank? && active_categories.blank?
      return h.content_tag(:dd) do
        h.link_to I18n.t('search.index.no_filters'), '#'
      end
    end

    ''.html_safe.tap do |ret|
      # Remove all
      ret << h.content_tag(:dd) do
        new_params = h.params.deep_dup.except!(:categories, :fq)
        h.link_to I18n.t('search.index.remove_all'), h.search_path(new_params)
      end

      # Categories and facets
      ret << active_categories.removal_links unless active_categories.blank?
      ret << facets.removal_links unless facets.blank?
    end
  end

  # Return a formatted version of the number of hits for the last search
  #
  # @api public
  # @return [String] number of hits for the search
  # @example Print the number of hits for the search (in HAML)
  #   = result.num_hits
  def num_hits
    if (object.params[:q] && object.params[:q] != '*:*') || object.params[:fq]
      I18n.t 'search.index.num_hits_found', count: object.num_hits
    else
      I18n.t 'search.index.num_documents_database', count: object.num_hits
    end
  end

  # Render the pagination links
  #
  # @api public
  # @return [String] full set of pagination links for the current page
  # @example Put the current pagination links in a paragraph element
  #   <p><%= result.pagination %></p>
  def pagination
    # Extract page and per_page from the Solr query that we called
    per_page = (object.params['rows'] || 10).to_i
    start = (object.params['start'] || 0).to_i
    page = start / per_page

    num_pages = object.num_hits.to_f / per_page.to_f
    num_pages = Integer(num_pages.ceil)
    return ''.html_safe if num_pages <= 1

    h.content_tag :ul, class: 'pagination' do
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
  end

  # Return an array of all sort methods
  #
  # @api public
  # @return [Array<String>] all possible sorting strings
  # @example Create links to all the sort methods
  #   <%= sort_methods.each do |s| %>
  #     <%= link_to ... %>
  def sort_methods
    SORT_METHODS.map { |m| [m, sort_string_for(m)] }
  end

  # Get the current sort method as a string
  #
  # @api public
  # @return [String] user-friendly representation of current sort method
  # @example Get the current search's sort method
  #   result.sort
  #   # => 'Sort: Relevance'
  def sort
    sort_string_for object.params['sort']
  end

  private

  # Make a link to a page for the pagination widget
  #
  # @api public
  # @param [String] text text for this link
  # @param [Integer] num the page number (0-based)
  # @param [String] klass class to put on the <li> tag
  # @return [String] the requested link
  # @example Get a link to the 3rd page of results
  #   page_link('Page 3!', 2)
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
      href = h.search_path(new_params)
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
  # @api private
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
