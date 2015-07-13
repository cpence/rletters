
module Admin
  # Representation of an administrator in the database
  #
  # Note that, for security, these users aren't even stored in the same table as
  # the standard signup users (it's impossible for a "normal" user to promote
  # themself to administrator).
  #
  # @!macro devise_user
  class Administrator < ActiveRecord::Base
    self.table_name = 'admin_administrators'

    devise :database_authenticatable, :recoverable, :rememberable,
           :trackable, :validatable

    def send_devise_notification(notification, *args)
      devise_mailer
        .send(notification, self, *args)
        .deliver_later(queue: :maintenance)
    end
  end
end
