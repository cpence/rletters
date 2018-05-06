# frozen_string_literal: true

# @!macro [new] devise_user
#   @!attribute email
#     @return [String] E-mail address (from Devise)
#   @!attribute encrypted_password
#     @return [String] Password (encrypted, from Devise)
#   @!attribute reset_password_token
#     @return [String] Token sent with reset password e-mail (from Devise)
#   @!attribute reset_password_sent_at
#     @return [DateTime] Time of the last reset password mail (from Devise)
#   @!attribute remember_created_at
#     @return [DateTime] Time at which the user last selected "remember me"
#       (from Devise)
#   @!attribute sign_in_count
#     @return [Integer] The number of logins for this user (from Devise)
#   @!attribute current_sign_in_at
#     @return [DateTime] The time at which the user currently signed in (from
#       Devise)
#   @!attribute last_sign_in_at
#     @return [DateTime] The last time this user signed in (from Devise)
#   @!attribute current_sign_in_ip
#     @return [String] The IP from which the user currently is logged in (from
#       Devise)
#   @!attribute last_sign_in_ip
#     @return [String] The IP from which the user last logged in (from Devise)
