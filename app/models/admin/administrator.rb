
module Admin
  # Representation of an administrator in the database
  #
  # Note that, for security, these users aren't even stored in the same table as
  # the standard signup users (it's impossible for a "normal" user to promote
  # themself to administrator).
  #
  # @!macro devise_user
  class Administrator < ApplicationRecord
    self.table_name = 'admin_administrators'

    devise :database_authenticatable, :rememberable, :trackable, :validatable

    # Override the Devise e-mail delivery logic to queue mail delivery
    #
    # We tap into this method to make sure that e-mails from Devise are
    # delivered in the background, on the maintenance queue.
    #
    # @param [Symbol] notification the notification to be sent
    # @param [Array] args the arguments for the message
    # @return [void]
    # :nocov:
    def send_devise_notification(notification, *args)
      devise_mailer
        .send(notification, self, *args)
        .deliver_later(queue: :maintenance)
    end
  end
  # :nocov:
end
