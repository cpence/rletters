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
#   @raise [RecordInvalid] if per_page is not an integer (validates :numericality)
#   @raise [RecordInvalid] if per_page is negative (validates :inclusion)
#   @return [Integer] Number of search results to display per page
# @!attribute language
#   @raise [RecordInvalid] if the language is missing (validates :presence)
#   @raise [RecordInvalid] if the language is not a valid language code (validates :format)
#   @return [String] Locale code of user's preferred language
# @!attribute timezone
#   @raise [RecordInvalid] if the timezone is missing (validates :presence)
#   @return [String] User's timezone, in Rails' format
# @!attribute csl_style_id
#   @return [Integer] User's preferred citation style (id of a CslStyle in database)
#
# @!attribute datasets
#   @raise [RecordInvalid] if any of the datasets are invalid (validates_associated)
#   @return [Array<Dataset>] All datasets created by the user (+has_many+)
# @!attribute libraries
#   @raise [RecordInvalid] if any of the libraries are invalid (validates_associated)
#   @return [Array<Library>] All library links added by the user (+has_many+)
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :presence => true
  validates :per_page, :presence => true
  validates :per_page, :numericality => { :only_integer => true }
  validates :per_page, :inclusion => { :in => 1..9999999999 }
  validates :language, :presence => true
  validates :language, :format => { :with => /\A[a-z]{2,3}(-[A-Z]{2})?\Z/u }
  validates :timezone, :presence => true

  has_many :datasets, :dependent => :delete_all
  has_many :libraries, :dependent => :delete_all

  validates_associated :datasets
  validates_associated :libraries

  # Attributes from Devise
  attr_accessible :email, :password, :password_confirmation, :remember_me

  # Attributes that can be edited by the user (in the user options form) 
  # should be whitelisted here.  Programmatic-access things (like datasets)
  # do *not* need to occur here.
  attr_accessible :name, :per_page, :language, :csl_style_id, :libraries, :timezone
  
  # Convert the +csl_style_id+ to a CslStyle (or nil)
  #
  # @api public
  # @return [CslStyle] the user's CSL style (or nil)
  # @example Format a document with a user's CSL style
  #   @document.to_csl_entry(@user.csl_style)
  #   # Note: Do *not* call to_csl_entry with @user.csl_style_id, it will fail!
  def csl_style
    CslStyle.find(self.csl_style_id) rescue nil
  end
end
