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

    # Build the return value
    tags = field_facets.map do |f|
      p = RLetters::Presenters::FacetPresenter.new(facet: f)

      new_facets = active_facets + [f]
      new_params = RLetters::Solr::Facets.search_params(params, new_facets)

      facet_add_link(new_params, f.hits.to_s, p.label)
    end

    safe_join(tags)
  end

  def facet_removal_links(facets)
    active_facets = facets.active(params)
    tags = []

    # Remove all link
    remove_params = params.except(:categories, :fq)
    remove_params = RLetters::Solr::Search.permit_params(remove_params)
    tags << facet_remove_link(remove_params, I18n.t('search.index.remove_all'))

    active_facets.each do |f|
      other_facets = active_facets.reject { |x| x == f }
      other_params = RLetters::Solr::Facets.search_params(params, other_facets)

      p = RLetters::Presenters::FacetPresenter.new(facet: f)
      tags << facet_remove_link(other_params, "#{p.field_label}: #{p.label}")
    end

    safe_join(tags)
  end

  def category_addition_tree(roots = Documents::Category.roots)
    tags = roots.map do |root|
      content_tag(:li) do
        category_add_link(root)
      end
    end

    safe_join(tags)
  end

  def category_removal_links
    tags = Documents::Category.active(params).map do |category|
      facet_remove_link(
        category.toggle_search_params(params),
        "#{Documents::Category.model_name.human}: #{category.name}"
      )
    end

    safe_join(tags)
  end

  private

  def facet_add_link(params, hits, label)
    link_to params, class: 'nav-link' do
      hits = content_tag(:div, hits.to_s,
                         class: 'float-right badge badge-light bg-white mt-1')

      safe_join([hits, label])
    end
  end

  def category_add_link(category)
    link_to category.toggle_search_params(params), class: 'nav-link' do
      contents = [
        check_box_tag("category_#{category.to_param}",
                      '1',
                      category.enabled?(params),
                      disabled: true),
        category.name
      ]

      if category.has_children?
        contents << category_addition_tree(category.children)
      end

      safe_join(contents)
    end
  end

  def facet_remove_link(params, label)
    link_to params, class: 'nav-link' do
      close = content_tag(:div, close_icon, class: 'float-right')

      safe_join([close, label])
    end
  end
end
