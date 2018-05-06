# frozen_string_literal: true

module Admin
  # View, edit, and order categorization of journals
  class CategoriesController < ApplicationController
    before_action :authenticate_admin!
    layout 'admin'

    # Show the full list of categories
    #
    # @return [void]
    def index; end

    # Update the order of the categories
    #
    # This is called by the Nestable JS code whenever the user drags around the
    # order of the categories.
    #
    # @return [void]
    def order
      # This will already have been deserialized by Rails, and is thus likely to
      # be an array (though maybe a Hash if there's only one of them).
      new_order = params[:order]
      new_order = [new_order] if new_order.is_a?(Hash)

      # Loop the roots and make them roots, then recursively set their children
      new_order.each do |h|
        id = h['id']
        category = Documents::Category.find(id)
        category.parent = nil
        category.save

        set_children_for(category, h)
      end

      head :no_content
    end

    # Show the details of an individual category
    #
    # @return [void]
    def show
      @category = Documents::Category.find(params[:id])

      render layout: false
    end

    # Show the category creation form
    #
    # @return [void]
    def new
      @journals = journal_list
      @category = Documents::Category.new

      render layout: false
    end

    # Create a new category
    #
    # @return [void]
    def create
      category = Documents::Category.create(category_params)
      if category.save
        redirect_to categories_path
      else
        redirect_to categories_path, alert: I18n.t('admin.categories.validation_error')
      end
    end

    # Show the edit form for an existing category
    #
    # @return [void]
    def edit
      @journals = journal_list
      @category = Documents::Category.find(params[:id])

      render layout: false
    end

    # Update the parameters of an existing category
    #
    # @return [void]
    def update
      category = Documents::Category.find(params[:id])
      category.update!(category_params)
      redirect_to categories_path
    end

    # Delete an individual category
    #
    # @return [void]
    def destroy
      category = Documents::Category.find(params[:id])
      category.destroy

      redirect_to categories_path
    end

    private

    # Whitelist acceptable category parameters
    #
    # @return [ActionController::Parameters] acceptable parameters for
    #   mass-assignment
    def category_params
      params.require(:documents_category).permit(:name, journals: [])
    end

    # Take the given hash and category, and set its children as appropriate
    #
    # @return [void]
    def set_children_for(category, hash)
      if hash['children']
        hash['children'].each do |ch|
          child = Documents::Category.find(ch['id'])
          child.parent = category
          child.save

          set_children_for(child, ch)
        end
      else
        # Can't remove children, so nil out the parent of anything that's listed
        # as a child of this node
        category.children.each do |c|
          c.parent = nil
          c.save
        end
      end
    end

    # Return a list of all journals that can be added to a category
    #
    # @return [Array<String>] all journals in the Solr index
    def journal_list
      ret = []
      offset = 0

      loop do
        result = RLetters::Solr::Connection.search(
          q: '*:*',
          def_type: 'lucene',
          rows: 1,
          'facet.count': '100',
          'facet.offset': offset.to_s
        )

        break unless result.facets

        facets = result.facets.for_field(:journal_facet)

        break unless facets
        break if facets.empty?

        available_facets = facets.map do |f|
          f.hits.positive? ? f.value : nil
        end

        available_facets.compact!
        break if available_facets.empty?

        ret.concat(available_facets)

        offset += 100
      end

      ret
    end
  end
end
