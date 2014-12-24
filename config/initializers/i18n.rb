
# Add vendor locales (for CLDR files)
Rails.application.config.i18n.load_path +=
  Dir[Rails.root.join('vendor',
                      'locales',
                      '**',
                      '*.{rb,yml}').to_s]

I18n.config.enforce_available_locales = true
Rails.application.config.i18n.default_locale = :en
