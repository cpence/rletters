# -*- encoding : utf-8 -*-

# Markup generators for the search controller
module SearchHelper

  # Return a formatted version of the number of hits for the last search
  #
  # @api public
  # @param [Solr::SearchResult] result the search result
  # @return [String] number of hits for the search
  # @example Print the number of hits for the search (in HAML)
  #   = num_hits_string(@result)
  def num_hits_string(result)
    if params[:precise] || params[:q] || params[:fq]
      I18n.t 'search.index.num_hits_found', count: result.num_hits
    else
      I18n.t 'search.index.num_documents_database', count: result.num_hits
    end
  end

  # Make a link to a page for the pagination widget
  #
  # @api public
  # @param [String] text text for this link
  # @param [Integer] num the page number (0-based)
  # @param [String] cl class to put on the <li> tag
  # @return [String] the requested link
  # @example Get a link to the 3rd page of results
  #   page_link('Page 3!', 2)
  def page_link(text, num, cl)
    if num.nil?
      href = '#'
    else
      new_params = params.dup
      if num == 0
        new_params.delete :page
      else
        new_params[:page] = num
      end
      href = search_path(new_params)
    end

    content_tag(:li, link_to(text, href), class: cl)
  end

  # Render the pagination links
  #
  # @api public
  # @param [Solr::SearchResult] result the search result
  # @return [String] full set of pagination links for the current page
  # @example Put the current pagination links in a paragraph element
  #   <p><%= render_pagination(@result) %></p>
  def render_pagination(result)
    num_pages = result.num_hits.to_f / @per_page.to_f
    num_pages = Integer(num_pages.ceil)
    return '' if num_pages <= 1

    content_tag :ul, class: 'pagination' do
      content = page_link('&laquo;'.html_safe,
                          @page == 0 ? nil : @page - 1,
                          @page == 0 ? 'unavailable' : nil)

      # Render at most seven pagination links
      if num_pages < 7
        range_to_render = (0..num_pages).to_a
      elsif @page < 3
        range_to_render = [0, 1, 2, 3, nil, num_pages - 2, num_pages - 1]
      elsif @page >= num_pages - 3
        range_to_render = [0, 1, nil, num_pages - 4, num_pages - 3,
                           num_pages - 2, num_pages - 1]
      else
        range_to_render = [0, nil, @page - 1, @page, @page + 1, nil,
                           num_pages - 1]
      end

      range_to_render.each do |p|
        if p.nil?
          content << page_link('&hellip;'.html_safe, nil, 'unavailable')
        else
          content << page_link((p + 1).to_s, p, @page == p ? 'current' : nil)
        end
      end

      content << page_link('&raquo;'.html_safe,
                           @page == num_pages - 1 ? nil : @page + 1,
                           @page == num_pages - 1 ? 'unavailable' : nil)

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
    ['score desc',
     'authors_sort asc',
     'authors_sort desc',
     'title_sort asc',
     'title_sort desc',
     'journal_sort asc',
     'journal_sort desc',
     'year_sort asc',
     'year_sort desc']
  end

  # Get the given sort method as a string
  #
  # This function converts a sort method ('relevance', 'title', 'author',
  # 'journal', 'year') and sort direction ('asc' or 'desc') into a
  # user-friendly string.
  #
  # @api public
  # @param [String] sort sorting string
  # @return [String] user-friendly representation of sort method
  # @example Get the user-friendly version of 'score desc'
  #   sort_to_string 'score desc'
  #   # => 'Sort: Relevance'
  def sort_to_string(sort)
    parts = sort.split(' ')
    return I18n.t('search.index.sort_unknown') unless parts.count == 2

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

  # Return a set of list items for faceted browsing
  #
  # This function queries both the active facets on the current search and the
  # available facets for authors, journals, and years.  It returns a set of
  # <li> elements (_not_ a <ul>), including list dividers.
  #
  # @api public
  # @param [Solr::SearchResult] result the search result
  # @return [String] set of list items for faceted browsing
  # @example Get all of the links for faceted browsing
  #   facet_link_list(@result)
  #   # "<li>Active Filters</li>...<li>Authors</li><li>"
  #     "<a href='...'>Johnson</a></li>..."
  def facet_link_list(result)
    # Bail now if there's no facet data (faceted down to one document)
    return ''.html_safe unless result.facets

    active_facets = get_active_facets(result)
    ret = ''.html_safe

    # Run the facet-list code for all three facet fields
    ret << list_links_for_facet(result,
                                :authors_facet,
                                I18n.t('search.index.authors_facet'),
                                active_facets)
    ret << list_links_for_facet(result,
                                :journal_facet,
                                I18n.t('search.index.journal_facet'),
                                active_facets)
    ret << list_links_for_facet(result,
                                :year,
                                I18n.t('search.index.year_facet'),
                                active_facets)
    ret
  end

  # Return a list of active facets for a Foundation sub-nav
  #
  # @api public
  # @param [Solr::SearchResult] result the search result
  # @return [String] active facets in <dd><a> tags
  # @example Get all of the facet removal links
  #   active_Facet_list(@result)
  #   # "<dd><a href='...'>Johnson</a></dd>..."
  def active_facet_list(result)
    # Bail now if there's no facet data (faceted down to one document)
    return ''.html_safe unless result.facets

    active_facets = get_active_facets(result)
    ret = ''.html_safe

    if active_facets.empty?
      ret << content_tag(:dd) do
        link_to I18n.t('search.index.no_filters'), '#'
      end

      return ret
    end

    return ''.html_safe if active_facets.empty?

    ret << content_tag(:dd) do
      facet_link I18n.t('search.index.remove_all'), []
    end

    active_facets.each do |f|
      ret << content_tag(:dd, class: 'active') do
        other_facets = active_facets.reject { |x| x == f }
        facet_link "#{f.field_label}: #{f.label}", other_facets
      end
    end

    ret
  end

  # Get the short, formatted representation of a document
  #
  # This function returns the short bibliographic entry for a document that
  # will appear in the search results list.  The formatting here depends on
  # the current user's settings.  By default, we use a jQuery Mobile-formatted
  # partial with an H3 and some P's.  The user can set, however, to format the
  # bibliographic entries using their favorite CSL style.
  #
  # @api public
  # @param [Document] doc document for which bibliographic entry is desired
  # @return [String] bibliographic entry for document
  # @example Get the entry for a given document
  #   document_bibliography_entry(Document.new(authors: 'W. Johnson',
  #                                            year: '2000'))
  #   # "Johnson, W. 2000. ..."
  def document_bibliography_entry(doc)
    if user_signed_in? && current_user.csl_style
      if doc.fulltext_url
        cloud_icon = content_tag(:span, '',
                                 'data-tooltip' => true,
                                 title: t('search.document.cloud_tooltip'),
                                 class: 'icon fi-upload-cloud has-tip')
      else
        cloud_icon = ''.html_safe
      end

      return doc.to_csl_entry(current_user.csl_style) + cloud_icon
    end

    render partial: 'document', locals: { document: doc }
  end

  private

  # Convert the active facet queries to facets
  #
  # This function converts the +params[:fq]+ string into a list of Facet
  # objects.  It is used by several parts of the facet-display code.
  #
  # @api private
  def get_active_facets(result)
    [].tap do |ret|
      if params[:fq]
        params[:fq].each do |query|
          ret << result.facets.for_query(query)
        end
        ret.compact!
      end
    end
  end

  # Create a link to the given set of facets
  #
  # This function converts an array of facets to a link (generated via
  # +link_to+) to the search page for that filtered query.  All
  # parameters other than +:fq+ are simply duplicated (including the search
  # query itself, +:q+).
  #
  # @api private
  def facet_link(text, facets)
    new_params = params.dup

    if facets.empty?
      new_params[:fq] = nil
      return link_to(text,
                     search_path(new_params),
                     data: { transition: 'none' })
    end

    new_params[:fq] = []
    facets.each { |f| new_params[:fq] << f.query }
    link_to text,
            search_path(new_params),
            data: { transition: 'none' }
  end

  # Get the list of facet links for one particular field
  #
  # This function takes the facets from the +Document+ class, checks them
  # against +active_facets+, and creates a set of list items.  It is used
  # by +facet_link_list+.
  #
  # @api private
  def list_links_for_facet(result, field, header, active_facets)
    return ''.html_safe unless result.facets

    # Get the facets for this field
    facets = (result.facets.sorted_for_field(field) - active_facets).take(5)

    # Bail if there's no facets
    ret = ''.html_safe
    return ret if facets.empty?

    # Slight hack; :authors_facet is first, so for all others, put a divider
    # between the various kinds of facet
    ret << content_tag(:li, '', class: 'divider') if field != :authors_facet

    # Build the return value
    ret << content_tag(:li, content_tag(:strong, header))
    facets.each do |f|
      ret << content_tag(:li) do
        # Get a label into the link as well
        count = content_tag(:span, f.hits.to_s, class: 'round secondary label')
        text = f.label.html_safe + '&nbsp;&nbsp;'.html_safe + count

        # Link to whatever the current facets are, plus the new one
        facet_link(text, active_facets + [f])
      end
    end

    ret
  end
end
