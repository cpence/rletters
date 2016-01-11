
module Documents
  # Decorate an array of category objects
  #
  # This class aggregates the decoration methods on individual categories for
  # an entire collection of categories.
  class Documents::CategoriesDecorator < Draper::CollectionDecorator
    include TreeDecoration

    # Decorate elements with the category decorator
    #
    # @return [Class] the class used to decorate collection elements
    def decorator_class
      Documents::CategoryDecorator
    end

    # Return a list of removal links
    #
    # Convert this array of categories into an array of `<dd>` tag removal
    # links.
    #
    # @return [String] removal links for this collection of categories
    def removal_links
      map(&:removal_link).reduce(&:+)
    end

    # Return a list of journal categories
    #
    # This function formats the tree of Documents::Category objects for
    # display in the faceting system.  Note that this starts at the global
    # root, regardless of the contents of the current array.
    #
    # @return [String] journal categories, formatted for display
    def link_tree
      return ''.html_safe if object.size == 0

      h.content_tag(:li,
                    h.content_tag(:strong, I18n.t('search.index.categories')),
                    class: 'filter-header') +
        h.content_tag_for(:li, Documents::Category.roots) do |root|
          Documents::CategoryDecorator.decorate(root).link_tree
        end
    end
  end
end
