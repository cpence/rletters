
module Documents
  # A category of journals
  #
  # RLetters supports categorization of journals, so that users can filter
  # results by journal type.  This is the class for each category in the tree.
  #
  # @!attribute parent_id
  #   @return [Integer] id of parent node, or `nil` (internal, used by
  #     `closure_tree`)
  # @!attribute sort_order
  #   @return [Integer] sort order field (internal, used by `closure_tree`)
  # @!attribute name
  #   @raise [RecordInvalid] if the name is missing (`validates :presence`)
  #   @return [String] name of the category
  # @!attribute journals
  #   @return [Array<String>] list of journals in this category
  class Category < ApplicationRecord
    self.table_name = 'documents_categories'
    validates :name, presence: true

    before_save :clean_journals
    serialize :journals, Array

    # Enable closure_tree
    acts_as_tree name_column: 'name', order: 'sort_order'

    # @return (see ApplicationRecord.admin_attributes)
    def self.admin_attributes
      {
        name: {},
        journals: { array: true }
      }
    end

    # @return (see ApplicationRecord.admin_configuration)
    def self.admin_configuration
      { tree: true }
    end

    # @return [String] string representation of this category
    def to_s
      name
    end

    # Returns the list of currently active categories
    #
    # @param [ActionController::Parameters] params the parameters to check
    # @return [Array<Category>] the list of categories active
    def self.active(params)
      [params[:categories] || []].flatten.map { |id| find(id) }
    end

    # Is this category enabled for these params, or no?
    #
    # @param [ActionController::Parameters] params the parameters to check
    # @return [Boolean] if true, category is enabled on these params
    def enabled?(params)
      params[:categories]&.include?(to_param)
    end

    # Generate parameters that would toggle this category on or off
    #
    # This function returns a copy of `params`, but with the parameters
    # changed such that this category and all of its descendant categories
    # are switched either on or off.
    #
    # @param [ActionController::Parameters] params the current parameters
    # @return [Hash] new parameters with this category and its descendants
    #   toggled
    def toggle_search_params(params)
      categories = params[:categories]&.dup || []

      if enabled?(params)
        categories -= self_and_ancestors.collect(&:to_param)
        categories -= self_and_descendants.collect(&:to_param)
      else
        categories.concat(self_and_descendants.collect(&:to_param))
      end
      categories.uniq!

      ret = params.except(:categories)
      ret[:categories] = categories unless categories.empty?

      RLetters::Solr::Search::permit_params(ret)
    end

    private

    # Clean up list of journals when created
    #
    # To support empty arrays, the admin interface will send us a blank item
    # when  a new category is created.  We want to prune that before the
    # object is saved.
    #
    # @return [void]
    def clean_journals
      journals.delete('')
    end
  end
end
