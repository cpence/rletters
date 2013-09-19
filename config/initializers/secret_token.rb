# -*- encoding : utf-8 -*-

if Rails.env.development? || Rails.env.test?
  # Just set the insecure tokens, it's fine
  RLetters::Application.config.secret_token = '944a502d8f4a8af313e40a102c916c9424cb97f2689e323a8674a41d73a8f6f2ccc94f35362da4e8ffe9d41ccb4f90d4a74fbfa4cfbdcaf234d125904ea0b563'
  RLetters::Application.config.secret_key_base = '2a34343e1dab869de63c25974cd9b3a2fdd25aba80ca00784394902a4a1e163820dbe630b5b0fc7c45e972cea2e742ccfb405492ca058a13eda66f16600bbe8f'
elsif !ActiveRecord::Base.connection.tables.include?('setting')
  # Set the insecure tokens, and shout at the user
  Rails.logger.warn 'Using insecure session tokens; this should only occur once, when first bringing up the database'
  RLetters::Application.config.secret_token = '944a502d8f4a8af313e40a102c916c9424cb97f2689e323a8674a41d73a8f6f2ccc94f35362da4e8ffe9d41ccb4f90d4a74fbfa4cfbdcaf234d125904ea0b563'
  RLetters::Application.config.secret_key_base = '2a34343e1dab869de63c25974cd9b3a2fdd25aba80ca00784394902a4a1e163820dbe630b5b0fc7c45e972cea2e742ccfb405492ca058a13eda66f16600bbe8f'
else
  # We have the settings table, generate proper keys
  Setting.secret_token = SecureRandom.hex(128) if Setting.secret_token.blank?
  RLetters::Application.config.secret_token = Setting.secret_token

  Setting.secret_key_base = SecureRandom.hex(128) if Setting.secret_key_base.blank?
  RLetters::Application.config.secret_key_base = Setting.secret_key_base
end
