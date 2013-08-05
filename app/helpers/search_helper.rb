# -*- encoding : utf-8 -*-

# Markup generators for the search controller
module SearchHelper

  # Return a formatted version of the number of documents in the last search
  #
  # @api public
  # @return [String] number of documents in the last search
  # @example Print the number of documents in the last search (in HAML)
  #   = num_results_string
  def num_results_string
    if params[:precise] || params[:q] || params[:fq]
      I18n.t 'search.index.num_results_found', count: Document.num_results
    else
      I18n.t 'search.index.num_results_database', count: Document.num_results
    end
  end

  # Make a link to a page for the pagination widget
  #
  # @api public
  # @param [String] text text for this link
  # @param [Integer] num the page number (0-based)
  # @param [String] icon icon for the button, if desired
  # @param [Boolean] right if true, put icon on the right side of the button
  # @return [String] the requested link
  # @example Get a link to the 3rd page of results, with a right-arrow icon
  #   page_link('Page 3!', 2, 'arrow-r', true)
  def page_link(text, num, icon = '', right = false)
    new_params = params.dup
    if num == 0
      new_params.delete :page
    else
      new_params[:page] = num
    end

    data = { transition: :none, role: :button }
    data[:icon] = icon unless icon.empty?
    data[:iconpos] = 'right' if right

    link_to text, search_path(new_params), data: data
  end

  # Render the pagination links
  #
  # We currently render four buttons, in a 4x1 grid: first, previous, next,
  # and last.  Pagination is difficult for an application like this; we don't
  # want infinite scroll, as there are far too many items, but full
  # pagination (like that on Google or Flickr) really doesn't work on mobile
  # devices.  So this is a compromise.
  #
  # @api public
  # @return [String] full set of pagination links for the current page
  # @example Put the current pagination links in a paragraph element
  #   <p><%= render_pagination %></p>
  def render_pagination
    num_pages = Document.num_results.to_f / @per_page.to_f
    num_pages = Integer(num_pages.ceil)
    return '' if num_pages == 0

    content_tag :div, class: 'ui-grid-c' do
      content = content_tag(:div, class: 'ui-block-a') do
        if @page != 0
          page_link(I18n.t('search.index.first_button'),
                    0,
                    'back')
        end
      end
      content << content_tag(:div, class: 'ui-block-b') do
        if @page != 0
          page_link(I18n.t('search.index.previous_button'),
                    @page - 1,
                    'arrow-l')
        end
      end

      content << content_tag(:div, class: 'ui-block-c') do
        if @page != (num_pages - 1)
          page_link(I18n.t('search.index.next_button'),
                    @page + 1,
                    'arrow-r',
                    true)
        end
      end
      content << content_tag(:div, class: 'ui-block-d') do
        if @page != num_pages - 1
          page_link(I18n.t('search.index.last_button'),
                    num_pages - 1,
                    'forward',
                    true)
        end
      end

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
    [
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

  # Create a link to the given set of facets
  #
  # This function converts an array of facets to a link (generated via
  # +link_to+) to the search page for that filtered query.  All
  # parameters other than +:fq+ are simply duplicated (including the search
  # query itself, +:q+).
  #
  # @api public
  # @param [String] text body of the link
  # @param [Array<Solr::Facet>] facets array of facets, possibly empty
  # @return [String] link to search for the given set of facets
  # @example Get a "remove all facets" link
  #   facet_link("Remove all facets", [])
  #   # => link_to "Remove all facets", search_path
  # @example Get a link to a given set of facets
  #   facet_link("Some facets", [...])
  #   # => link_to "Some facets", search_path({ fq: [ ... ] })
  def facet_link(text, facets)
    new_params = params.dup

    if facets.empty?
      new_params[:fq] = nil
      return link_to text,
                     search_path(new_params),
                     data: { transition: 'none' }
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
  # @api public
  # @param [Symbol] field field we're faceting on
  # @param [String] header content of list item header
  # @param [Array<Solr::Facet>] active_facets array of active facets
  # @return [String] list items for links for the given facet
  # @example Get the links for the authors facet
  #   list_links_for_facet(:authors_facet, "Authors", [...])
  #   # "<li><a href='...'>Johnson <span class='ui-li-count'>2</a></li>..."
  def list_links_for_facet(field, header, active_facets)
    return ''.html_safe unless Document.facets

    # Get the facets for this field
    facets = (Document.facets.sorted_for_field(field) - active_facets).take(5)

    # Bail if there's no facets
    ret = ''.html_safe
    return ret if facets.empty?

    # Build the return value
    ret << content_tag(:li, header, data: { role: 'list-divider' })
    facets.each do |f|
      ret << content_tag(:li) do
        # Link to whatever the current facets are, plus the new one
        link = facet_link f.label, active_facets + [f]
        count = content_tag :span, f.hits.to_s, class: 'ui-li-count'
        link + count
      end
    end

    ret
  end

  # Return a set of list items for faceted browsing
  #
  # This function queries both the active facets on the current search and the
  # available facets for authors, journals, and years.  It returns a set of
  # <li> elements (_not_ a <ul>), including list dividers.
  #
  # @api public
  # @return [String] set of list items for faceted browsing
  # @example Get all of the links for faceted browsing
  #   facet_link_list
  #   # "<li>Active Filters</li>...<li>Authors</li><li>"
  #     "<a href='...'>Johnson</a></li>..."
  def facet_link_list
    # Make sure there are facets
    return ''.html_safe unless Document.facets

    # Convert the active facet queries to facets
    active_facets = []
    if params[:fq]
      params[:fq].each do |query|
        active_facets << Document.facets.for_query(query)
      end
      active_facets.compact!
    end

    # Start with the active facets
    ret = ''.html_safe
    unless active_facets.empty?
      ret << content_tag(:li,
                         I18n.t('search.index.active_filters'),
                         data: { role: 'list-divider' })
      ret << content_tag(:li, data: { icon: 'delete' }) do
        facet_link I18n.t('search.index.remove_all'), []
      end
      active_facets.each do |f|
        ret << content_tag(:li, data: { icon: 'delete' }) do
          other_facets = active_facets.reject { |x| x == f }
          facet_link "#{f.field_label}: #{f.label}", other_facets
        end
      end
    end

    # Run the facet-list code for all three facet fields
    ret << list_links_for_facet(:authors_facet,
                                I18n.t('search.index.authors_facet'),
                                active_facets)
    ret << list_links_for_facet(:journal_facet,
                                I18n.t('search.index.journal_facet'),
                                active_facets)
    ret << list_links_for_facet(:year,
                                I18n.t('search.index.year_facet'),
                                active_facets)
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
      return doc.to_csl_entry(current_user.csl_style)
    end

    render partial: 'document', locals: { document: doc }
  end
end
