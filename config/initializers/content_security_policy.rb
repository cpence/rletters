# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy
#
# FIXME: We would really rather not specify :data for img and :unsafe_inline
# for style, but at the moment, we have no choice if we want Bootstrap 4's
# custom form styles to actually work. There is a bug report:
# https://github.com/twbs/bootstrap/issues/25394
# but so far the Bootstrap folks don't seem very concerned about it.
#
# The 'gstatic.com' URLs, as well as the :unsafe_eval in script_src, are
# required by the Google Charts API.
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :none
  policy.img_src     :self, :data, 'https://ssl.gstatic.com'
  policy.object_src  :none
  policy.script_src  :self, :unsafe_eval, 'https://www.google.com', 'https://www.gstatic.com'
  policy.style_src   :self, :unsafe_inline, 'https://www.gstatic.com'
end

# Enable automatic nonce generation for UJS
Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }
