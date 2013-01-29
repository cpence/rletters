# -*- encoding : utf-8 -*-

# Representation of an administrator in the database
#
# Note that, for security, these users aren't even stored in the same table as
# the standard signup users (it's impossible for a "normal" user to promote
# themself to administrator).
#
# @!attribute email
#   @return [String] E-mail address (from Devise)
# @!attribute password
#   @return [String] Password (encrypted, from Devise)
# @!attribute password_confirmation
#   @return [String] Password confirmation field (encrypted, from Devise)
# @!attribute remember_me
#   @return [Boolean] Whether to keep user logged in (from Devise)
class AdminUser < ActiveRecord::Base
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :email, :password, :password_confirmation, :remember_me
end
