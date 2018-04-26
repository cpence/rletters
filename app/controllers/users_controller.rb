
# Supplemental actions for users
#
# We add a number of actions for users that aren't part of the standard Devise
# suite.
class UsersController < ApplicationController
  before_action :authenticate_user!

  # Start a job to build an export
  #
  # @return [void]
  def export_create
    unless current_user.can_export?
      fail ArgumentError, 'user has exported too recently'
    end

    UserExportJob.perform_later(current_user)

    current_user.export_requested_at = DateTime.now
    current_user.save

    redirect_to edit_user_registration_path
  end

  # Remove the user's export file, if it exists
  #
  # @return [void]
  def export_delete
    unless current_user.export_archive.attached?
      fail ActiveRecord::RecordNotFound
    end

    current_user.export_archive.purge_later

    redirect_to edit_user_registration_path
  end
end
