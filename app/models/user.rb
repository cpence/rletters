# -*- encoding : utf-8 -*-

# Representation of a user in the database
#
# RLetters keeps track of users so that it can send e-mails regarding
# background jobs and keep a set of customizable user options.
#
# @!attribute name
#   @raise [RecordInvalid] if the name is missing (validates :presence)
#   @return [String] Full name
# @!attribute email
#   @return [String] E-mail address
# @!attribute password
#   @return [String] Password (encrypted, from Devise)
# @!attribute password_confirmation
#   @return [String] Password confirmation field (encrypted, from Devise)
# @!attribute remember_me
#   @return [Boolean] Whether to keep user logged in (from Devise)
#
# @!attribute per_page
#   @raise [RecordInvalid] if per_page is missing (validates :presence)
#   @raise [RecordInvalid] if per_page is not an integer (validates
#     :numericality)
#   @raise [RecordInvalid] if per_page is negative (validates :inclusion)
#   @return [Integer] Number of search results to display per page
# @!attribute language
#   @raise [RecordInvalid] if the language is missing (validates :presence)
#   @raise [RecordInvalid] if the language is not a valid language code
#     (validates :format)
#   @return [String] Locale code of user's preferred language
# @!attribute timezone
#   @raise [RecordInvalid] if the timezone is missing (validates :presence)
#   @return [String] User's timezone, in Rails' format
# @!attribute csl_style_id
#   @return [Integer] User's preferred citation style (id of a
#     Users::CslStyle in database)
#
# @!attribute datasets
#   @raise [RecordInvalid] if any of the datasets are invalid
#     (validates_associated)
#   @return [Array<Dataset>] All datasets created by the user (+has_many+)
# @!attribute libraries
#   @raise [RecordInvalid] if any of the libraries are invalid
#     (validates_associated)
#   @return [Array<Users::Library>] All library links added by the user
#     (+has_many+)
#
# @!attribute workflow_active
#   @return [Boolean] True if the user is currently building a query in the
#     workflow controller
# @!attribute workflow_class
#   @return [String] If set, the class the user has selected to perform in the
#     workflow controller
# @!attribute workflow_datasets
#   @return [String] An array of the datasets the user has selected to perform
#     in the workflow controller
class User < ActiveRecord::Base
  devise :async, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true
  validates :per_page, presence: true,
                       numericality: { only_integer: true },
                       inclusion: { in: 1..999_999_999 }
  validates :language, presence: true,
                       format: { with: /\A[a-z]{2,3}(-[A-Z]{2})?\Z/ }
  validates :timezone, presence: true

  has_many :datasets
  has_many :libraries, class_name: 'Users::Library'

  # Convert the +csl_style_id+ to a CslStyle (or nil)
  #
  # @api public
  # @return [Users::CslStyle] the user's CSL style (or nil)
  # @example Format a document with a user's CSL style
  #   @document.to_csl_entry(@user.csl_style)
  #   # Note: Do *not* call to_csl_entry with @user.csl_style_id, it will fail!
  def csl_style
    Users::CslStyle.find_by(id: csl_style_id)
  end

  # Parameter sanitizer class for regular users
  #
  # Attributes that can be edited by the user (in the user options form)
  # should be whitelisted here.  This should be kept in sync with the views
  # in users/registrations/{edit,new}.html.
  #
  # This class is not tested, as it's only ever called from within the
  # internals of Devise.
  #
  # @see ApplicationController::devise_parameter_sanitizer
  # :nocov:
  class ParameterSanitizer < Devise::ParameterSanitizer
    # Permit the parameters used in the sign up form
    # @return [ActionController::Parameters] permitted parameters
    def sign_up
      default_params.permit(:name, :email, :password, :password_confirmation,
                            :language, :timezone)
    end

    # Permit the parameters used in the user edit form
    # @return [ActionController::Parameters] permitted parameters
    def account_update
      default_params.permit(:name, :email, :password, :password_confirmation,
                            :current_password, :language, :timezone, :per_page,
                            :csl_style_id)
    end
  end
  # :nocov:
end
