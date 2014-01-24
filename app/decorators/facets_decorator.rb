# -*- encoding : utf-8 -*-

class FacetsDecorator < Draper::Decorator
  delegate_all

  # Return a set of list items for faceted browsing
  #
  # This function queries both the active facets on the current search and the
  # available facets for authors, journals, and years.  It returns a set of
  # <li> elements (_not_ a <ul>), including list dividers.
  #
  # @api public
  # @return [String] set of list items for faceted browsing
  # @example Get all of the links for faceted browsing
  #   @facets.addition_links
  #   # "<li>Active Filters</li>...<li>Authors</li><li>"
  #     "<a href='...'>Johnson</a></li>..."
  def addition_links
    active = active_facets
    ret = ''.html_safe

    # Run the facet-list code for all three facet fields
    ret << addition_links_for_field(:authors_facet,
                                    I18n.t('search.index.authors_facet'),
                                    active_facets)
    ret << addition_links_for_field(:journal_facet,
                                    I18n.t('search.index.journal_facet'),
                                    active_facets)
    ret << addition_links_for_field(:year,
                                    I18n.t('search.index.year_facet'),
                                    active_facets)
    ret
  end

  # Return a set of tags for removing the active facets
  #
  # This function turns the list of active facets into a list of facet-removing
  # links.  It returns a set of <dd> tags, desgined to be put into a <dl>.
  #
  # @api public
  # @return [String] set of list items for faceted browsing
  # @example Get all of the links for faceted browsing
  #   @facets.removal_links
  #   # "<dd><a href='...'>Author: A. One</dd>..."
  def removal_links
    active = active_facets
    ret = ''.html_safe

    if active_facets
      active_facets.each do |f|
        ret << h.content_tag(:dd, class: 'active') do
          other_facets = active_facets.reject { |x| x == f }

          f = FacetDecorator.decorate(f)
          link_to_facets("#{f.field_label}: #{f.label}", other_facets)
        end
      end
    end

    ret
  end

  private

  # Convert the active facet queries to facets
  #
  # This function converts the +params[:fq]+ string into a list of Facet
  # objects.  It is used by several parts of the facet-display code.
  #
  # @api private
  def active_facets
    [].tap do |ret|
      if h.params[:fq]
        h.params[:fq].each do |query|
          ret << for_query(query)
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
  def link_to_facets(text, facets)
    new_params = h.params.deep_dup

    if facets.empty?
      new_params[:fq] = nil
      return h.link_to(text, h.search_path(new_params))
    end

    new_params[:fq] = []
    facets.each { |f| new_params[:fq] << f.query }
    h.link_to(text, h.search_path(new_params))
  end

  # Get the list of facet links for one particular field
  #
  # This function takes the facets from the +Document+ class, checks them
  # against +active_facets+, and creates a set of list items.  It is used
  # by +links_for_addition+.
  #
  # @api private
  def addition_links_for_field(field, header, active_facets)
    # Get the facets for this field
    facets = (sorted_for_field(field) - active_facets).take(5)

    # Bail if there's no facets
    ret = ''.html_safe
    return ret if facets.empty?

    # Slight hack; :authors_facet is first, so for all others, put a divider
    # between the various kinds of facet
    ret << h.content_tag(:li, '', class: 'divider') if field != :authors_facet

    # Build the return value
    ret << h.content_tag(:li, h.content_tag(:strong, header))
    facets.each do |f|
      ret << h.content_tag(:li) do
        f = FacetDecorator.decorate(f)

        # Get a label into the link as well
        count = h.content_tag(:span, f.hits.to_s, class: 'round secondary label')
        text = f.label + '&nbsp;&nbsp;'.html_safe + count

        # Link to whatever the current facets are, plus the new one
        link_to_facets(text, active_facets + [f])
      end
    end

    ret
  end
end
