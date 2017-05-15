
# We are using webpacker, *not* the traditional asset pipeline
Rails.application.config.assets.enabled = false

# We don't actually precompile this (it's just in memory), but it raises an
# error if we don't have this here.
Rails.application.config.assets.precompile += %w{foundation_emails.css}
