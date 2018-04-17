
# A few custom user-related actions
#
# Most of the user interaction is handled by Devise, but we have a few actions
# that they don't support. Those are handled here.
class UsersController < ApplicationController
  layout 'full_page'
  before_action :authenticate_user!

  # Download the user's export archive, if it exists
  #
  # @return [void]
  def export
    # Shouldn't be possible, but check it anyway
    fail ActiveRecord::RecordNotFound unless user_signed_in?

    # If they don't have an export generated, 404
    fail ActiveRecord::RecordNotFound unless current_user.export_archive?

    send_data(Paperclip.io_adapters.for(current_user.export_archive),
              filename: 'export.zip',
              type: current_user.export_archive_content_type)
  end
end
