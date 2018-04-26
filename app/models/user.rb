
# Representation of a user in the database
#
# RLetters keeps track of users so that it can send e-mails regarding
# background jobs and keep a set of customizable user options.
#
# @!attribute name
#   @raise [RecordInvalid] if the name is missing (`validates :presence`)
#   @return [String] Full name
# @!attribute email
#   @return [String] Email address
#
# @!attribute language
#   @raise [RecordInvalid] if the language is missing (`validates :presence`)
#   @raise [RecordInvalid] if the language is not a valid language code
#     (`validates :format`)
#   @return [String] Locale code of user's preferred language
# @!attribute timezone
#   @raise [RecordInvalid] if the timezone is missing (`validates :presence`)
#   @return [String] User's timezone, in Rails' format
# @!attribute csl_style_id
#   @return [Integer] User's preferred citation style (id of a
#     Users::CslStyle in database)
#
# @!attribute datasets
#   @raise [RecordInvalid] if any of the datasets are invalid
#     (`validates_associated`)
#   @return [Array<Dataset>] All datasets created by the user (`has_many`)
# @!attribute libraries
#   @raise [RecordInvalid] if any of the libraries are invalid
#     (`validates_associated`)
#   @return [Array<Users::Library>] All library links added by the user
#     (`has_many`)
#
# @!attribute workflow_active
#   @return [Boolean] True if the user is currently building a query in the
#     workflow controller
# @!attribute workflow_class
#   @return [String] If set, the class the user has selected to perform in the
#     workflow controller
# @!attribute workflow_datasets
#   @return [Array<Dataset>] An array of the datasets the user has selected
#     to perform in the workflow controller
#
# @!attribute export_archive
#   @return [ActiveStorage::Attachment] The user's data, collected as a ZIP
#     file archive
# @!attribute export_requested_at
#   @return [DateTime] The time at which the user last requested a data export
#
# @!macro devise_user
class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable

  validates :name, presence: true
  validates :language, presence: true,
                       format: { with: /\A[a-z]{2,3}(-[A-Z]{2})?\Z/ }
  validates :timezone, presence: true

  has_many :datasets
  has_many :libraries, class_name: 'Users::Library'

  has_one_attached :export_archive

  # @return [String] string representation of this user
  def to_s
    "#{name} <#{email}>"
  end

  # Get a particular workflow dataset for this user
  #
  # The `workflow_datasets` attribute is an array of ID values, so this will
  # convert them into actual dataset objects.
  #
  # @param [Integer] n the number of the dataset to return
  # @raise [RecordNotFound] if the index is outside the range for the number
  #   of datasets in the user's workflow
  # @return [Dataset] the given dataset
  def workflow_dataset(n)
    fail ActiveRecord::RecordNotFound if workflow_datasets.size <= n
    Dataset.find(workflow_datasets[n])
  end

  # Get the user's CSL style, converting from `csl_style_id`
  #
  # @return [Users::CslStyle] the user's CSL style (or `nil`)
  def csl_style
    Users::CslStyle.find_by(id: csl_style_id)
  end

  # Returns true if the user is allowed to start another export job
  #
  # @return [Boolean] true if the user can export their data now
  def can_export?
    return true unless export_requested_at
    return export_requested_at < 1.day.ago
  end

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
  # :nocov:

  # Parameter sanitizer class for regular users
  #
  # Attributes that can be edited by the user (in the user options form)
  # should be whitelisted here.  This should be kept in sync with the views
  # in users/registrations/{ edit, new }.html.
  #
  # This class is not tested, as it's only ever called from within the
  # internals of Devise.
  #
  # @see ApplicationController::devise_parameter_sanitizer
  # :nocov:
  class ParameterSanitizer < Devise::ParameterSanitizer
    # Permit the parameters used in the sign up and user edit forms
    # @return [ActionController::Parameters] permitted parameters
    def initialize(*)
      super
      permit(:sign_up,
             keys: [:name, :email, :password, :password_confirmation,
                    :language, :timezone])
      permit(:account_update,
             keys: [:name, :email, :password, :password_confirmation,
                    :current_password, :language, :timezone, :csl_style_id])
    end
  end
  # :nocov:
end
