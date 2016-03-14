
# Code for objects belonging to users
module Users
  # Representation of a library-owned OpenURL resolver
  #
  # @!attribute name
  #   @raise [RecordInvalid] if the name is missing (validates :presence)
  #   @return [String] The name of the library
  # @!attribute url
  #   @raise [RecordInvalid] if the URL is missing (validates :presence)
  #   @raise [RecordInvalid] if the URL is not a valid URL (validates :format)
  #   @return [String] The base URL for its OpenURL resolver
  # @!attribute user
  #   @raise [RecordInvalid] if the user is missing (validates :presence)
  #   @return [User] The user this library record belongs to
  class Library < ApplicationRecord
    self.table_name = 'users_libraries'
    belongs_to :user

    validates :name, presence: true
    validates :url, presence: true, format: {
      with: %r{\A(https?)://[^\s/$.?#].[^\s]*\z}i,
    }
    validates :user_id, presence: true

    before_validation do |library|
      library.url = 'http://' + (url || '') unless library.url&.include?('://')
    end

    after_validation do |library|
      library.url << '?' unless library.url&.end_with?('?')
    end

    # @return (see ApplicationRecord.admin_attributes)
    def self.admin_attributes
      {
        user: { model: true },
        name: {},
        url: {}
      }
    end

    # @return [String] string representation of this library
    def to_s
      name
    end
  end
end
