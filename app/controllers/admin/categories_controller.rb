
module Admin
  class CategoriesController < ApplicationController
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
      puts params
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
      category.destroy()

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
          'facet.offset': offset.to_s)

        break unless result.facets

        facets = result.facets.for_field(:journal_facet)

        break unless facets
        break if facets.empty?

        available_facets = facets.map do |f|
          f.hits > 0 ? f.value : nil
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
