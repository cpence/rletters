# -*- encoding : utf-8 -*-

class SearchResultDecorator < Draper::Decorator
  decorates RLetters::Solr::SearchResult
  delegate_all

  # Return a formatted version of the number of hits for the last search
  #
  # @api public
  # @return [String] number of hits for the search
  # @example Print the number of hits for the search (in HAML)
  #   = result.num_hits
  def num_hits(q = nil, fq = nil, precise = nil)
    if q || fq || precise
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
  def pagination(page = 0, per_page = 10)
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
end
