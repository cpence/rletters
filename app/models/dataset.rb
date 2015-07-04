
# The saved results of a given search, for analysis
#
# A dataset is the result set from a given search, persisted in the database
# so that we can run digital humanities analyses on a collection of documents.
#
# @!attribute name
#   @raise [RecordInvalid] if the name is missing (`validates :presence`)
#   @return [String] The name of this dataset
# @!attribute user
#   @raise [RecordInvalid] if the user is missing (`validates :presence`)
#   @return [User] The user that owns this dataset
# @!attribute disabled
#   @return [Boolean] true if this dataset cannot be used (is currently being
#     built)
# @!attribute fetch
#   @return [Boolean] true if at least one document in this dataset must be
#     fetched over an external connection
# @!attribute entries
#   @raise [RecordInvalid] if any of the entries are invalid
#     (`validates_associated`)
#   @return [Array<Datasets::Entry>] The documents contained in this dataset
#     (`has_many`)
# @!attribute tasks
#   @return [Array<Datasets::Task>] The tasks run on this dataset (`has_many`)
class Dataset < ActiveRecord::Base
  validates :name, presence: true
  validates :user_id, presence: true

  belongs_to :user
  has_many :entries, class_name: 'Datasets::Entry'
  has_many :tasks, class_name: 'Datasets::Task', dependent: :destroy

  # @return [Array<Dataset>] all datasets that are currently not disabled
  scope :active, -> { where(disabled: false) }
  # @return [Array<Dataset>] all datasets that are currently disabled
  scope :inactive, -> { where(disabled: true) }
end
