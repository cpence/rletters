# -*- encoding : utf-8 -*-

# Representation of an administrator in the database
#
# Note that, for security, these users aren't even stored in the same table as
# the standard signup users (it's impossible for a "normal" user to promote
# themself to administrator).
#
# @attr [String] email E-mail address (from Devise)
# @attr [String] password Password (encrypted, from Devise)
# @attr [String] password_confirmation Password confirmation field (encrypted, from Devise)
# @attr [Boolean] remember_me Whether to keep user logged in (from Devise)
class AdminUser < ActiveRecord::Base
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable
  attr_accessible :email, :password, :password_confirmation, :remember_me
end
