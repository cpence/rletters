# frozen_string_literal: true

module SearchHelper
  # Get the list of facet links for one particular field
  #
  # This function takes the facets from the `Document` class, checks them
  # against the active facets, and creates a set of list items.
  #
  # @param [RLetters::Solr::Facets] facets the facets returned
  # @param [Symbol] field the field to return links for
  # @return [String] the built markup of addition links for this field
  def facet_addition_links(facets, field)
    # Get the facets for this field
    active_facets = facets.active(params)
    field_facets = (facets.sorted_for_field(field) - active_facets).take(5)

    # Bail if there's no facets
    return ''.html_safe if field_facets.empty?

    # Build the return value
    tags = field_facets.map do |f|
      p = RLetters::Presenters::FacetPresenter.new(facet: f)
      render(partial: 'search/filters/facet_add_link', locals: {
               hits: f.hits.to_s,
               label: p.label,
               facets: active_facets + [f]
             })
    end

    tags.join.html_safe
  end

  def facet_removal_links(facets)
    active_facets = facets.active(params)
    tags = active_facets.map do |f|
      other_facets = active_facets.reject { |x| x == f }

      p = RLetters::Presenters::FacetPresenter.new(facet: f)
      render(
        partial: 'search/filters/facet_remove_link',
        locals: {
          params: RLetters::Solr::Facets.search_params(params, other_facets),
          label: "#{p.field_label}: #{p.label}"
        }
      )
    end

    tags.join.html_safe
  end

  def category_addition_tree(roots = Documents::Category.roots)
    tags = roots.map do |root|
      content_tag(:li) do
        render(partial: 'search/filters/category_add_link',
               locals: { category: root })
      end
    end

    tags.join.html_safe
  end

  def category_removal_links
    tags = Documents::Category.active(params).map do |category|
      render(
        partial: 'search/filters/facet_remove_link',
        locals: {
          params: category.toggle_search_params(params),
          label: "#{Documents::Category.model_name.human}: #{category.name}"
        }
      )
    end

    tags.join.html_safe
  end
end
