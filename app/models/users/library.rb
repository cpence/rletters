
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
  #   @return [User] The user this library entry belongs to
  class Library < ActiveRecord::Base
    self.table_name = 'users_libraries'
    belongs_to :user

    validates :name, presence: true
    validates :url, presence: true, url: true
    validates :user_id, presence: true

    before_validation do |library|
      library.url = 'http://' + url if library.url && !library.url.include?('://')
    end

    after_validation do |library|
      library.url += '?' if library.url && !library.url.end_with?('?')
    end
  end
end
