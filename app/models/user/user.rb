# -*- encoding : utf-8 -*-

# Representation of a user in the database
#
# RLetters keeps track of users so that it can send e-mails regarding
# background jobs and keep a set of customizable user options.
#
# @attr [String] name Full name
# @attr [String] email E-mail address
# @attr [String] password Password (encrypted, from Devise)
# @attr [String] password_confirmation Password confirmation field (encrypted, from Devise)
# @attr [Boolean] remember_me Whether to keep user logged in (from Devise)
#
# @attr [Integer] per_page Number of search results to display per page
# @attr [String] language Locale code of user's preferred language
# @attr [String] timezone User's timezone, in Rails' format
# @attr [Integer] csl_style_id User's preferred citation style (id of a CslStyle in database)
#
# @attr [Array<Dataset>] datasets All datasets created by the user (+has_many+)
# @attr [Array<Library>] libraries All library links added by the user (+has_many+)
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
