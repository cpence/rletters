# -*- encoding : utf-8 -*-

# A category of journals
#
# RLetters supports categorization of journals, so that users can filter
# results by journal type.  This is the class for each category in the tree.
#
# @!attribute parent_id
#   @return [Integer] id of parent node, or +nil+ (internal, used by
#     +closure_tree+)
# @!attribute sort_order
#   @return [Integer] sort order field (internal, used by +closure_tree+)
# @!attribute name
#   @raise [RecordInvalid] if the name is missing (validates :presence)
#   @return [String] name of the category
# @!attribute journals
#   @return [Array<String>] list of journals in this category
class Documents::Category < ActiveRecord::Base
  self.table_name = 'documents_categories'
  validates :name, presence: true
  serialize :journals, Array

  # Enable closure_tree
  acts_as_tree name_column: 'name', order: 'sort_order'

  # Clean up list of journals when created
  #
  # To support empty arrays, ActiveAdmin will send us a blank item when
  # a new category is created.  We want to prune that before the object is
  # saved.
  before_save do
    journals.delete('')
  end
end
