
module Users
  # Decorate Library objects
  class LibraryDecorator < ApplicationRecordDecorator
    decorates Users::Library
    delegate_all

    decorates_association :user, with: UserDecorator
  end
end
