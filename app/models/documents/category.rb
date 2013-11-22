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
  validates :name, presence: true
  serialize :journals, Array

  # Set table name manually
  #
  # For some reason, this model doesn't pick up Documents.table_name_prefix.
  # Fix it here.
  self.table_name = 'documents_categories'

  # Enable closure_tree
  acts_as_tree name_column: 'name', order: 'sort_order'
end
