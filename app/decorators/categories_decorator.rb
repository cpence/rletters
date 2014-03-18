# -*- encoding : utf-8 -*-

class CategoriesDecorator < Draper::CollectionDecorator
  # Decorate elements with the category decorator
  def decorator_class
    CategoryDecorator
  end

  # Return a list of removal links
  #
  # Convert this array of categories into an array of +<dd>+ tag removal
  # links.
  #
  # @api public
  # @return [String] removal links for this collection of categories
  # @example Removal links for all active categories
  #   = result.active_categories.removal_links
  def removal_links
    map { |c| c.removal_link }.reduce(&:+)
  end

  # Return a list of journal categories
  #
  # This function formats the tree of Documents::Category objects for
  # display in the faceting system.  Note that this starts at the global
  # root, regardless of the contents of the current array.
  #
  # @api public
  # @return [String] journal categories, formatted for display
  # @example Display the journal categories
  #   <%= result.categories.link_tree %>
  #   # "<ul><li>Category<ul>..."
  def link_tree
    return ''.html_safe if object.size == 0

    h.content_tag(:li, h.content_tag(:strong, I18n.t('search.index.categories'))) +
      h.content_tag_for(:li, Documents::Category.roots) do |root|
        CategoryDecorator.decorate(root).link_tree
      end
  end
end
