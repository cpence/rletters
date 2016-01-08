
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

    private

    # Clean up list of journals when created
    #
    # To support empty arrays, ActiveAdmin will send us a blank item when
    # a new category is created.  We want to prune that before the object is
    # saved.
    #
    # @return [void]
    def clean_journals
      journals.delete('')
    end
  end
end
