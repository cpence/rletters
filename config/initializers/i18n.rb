# Enable pluralization and language fallbacks (from 'de-DE' to 'de')
require 'i18n/backend/fallbacks'
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
require 'i18n/backend/pluralization'
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

# Raise errors if we try to use a locale that isn't available
I18n.config.enforce_available_locales = true

# Add search path to vendor locales (for CLDR files)
Rails.application.config.i18n.load_path +=
  Dir[Rails.root.join('vendor', 'locales', '**', '*.{rb,yml}').to_s]

# Set the list of available locales ('en' ships with Rails)
Rails.application.config.i18n.default_locale = :en
Rails.application.config.i18n.available_locales = ['en']

# Always use the fallbacks
Rails.application.config.i18n.fallbacks = true

# This exact line is taken from the README file of the rails-i18n gem, which
# supplies localizations for all our Rails defaults.
#
# Note: When you update this list from rails-i18n, you *must* copy over the
# appropriate CLDR files into vendor/locales/cldr.
#
# Exclude any languages that have a Rails translation but are not recognized
# by the CLDR, as we *require* the CLDR data files (at least 'languages.yml',
# 'plurals.rb' (if available), and 'territories.yml').  Currently this
# excludes the following languages:
# - lb (or ltz, Luxembourgish, not in CLDR at all)
# - tt (or tat, Tatar, not in CLDR at all)
# - wo (or wol, Wolof, not in CLDR at all)
# - zh-YUE (Yue Chinese, not in CLDR at all)
#
# Some languages in the CLDR have different codes in the CLDR:
# - tl (Tagalog) in Rails is fil (Filipino) in the CLDR
# - zh-CN (Chinese-China) in Rails is zh-Hans (Chinese-Simplified) in the CLDR
# - zh-TW (Chinese-Taiwan) in Rails is zh-Hant (Chinese-Traditional) in the
#   CLDR
# - zh-HK (Chinese-Hong Kong) in Rails is zh-Hant-HK (Chinese-Traditional-Hong
#   Kong) in the CLDR
#
# For the moment, I've decided to manually process these languages and rename
# them in the CLDR vendored data files.  There is a Rake task for this purpose
# in lib/tasks/locales.rake.
'af, ar, az, be, bg, bn, bs, ca, cs, cy, da, de, de-AT, de-CH, de-DE, el, ' \
'en-AU, en-CA, en-GB, en-IE, en-IN, en-NZ, en-ZA, eo, es, es-419, es-AR, ' \
'es-CL, es-CO, es-CR, es-EC, es-ES, es-MX, es-PA, es-PE, es-US, es-VE, et, ' \
'eu, fa, fi, fr, fr-CA, fr-CH, fr-FR, gl, he, hi, hi-IN, hr, hu, id, is, ' \
'it, it-CH, ja, km, kn, ko, lo, lt, lv, ml, mk, mn, mr-IN, ms, nb, ne, nl, ' \
'nn, or, pa, pl, pt, pt-BR, rm, ro, ru, sk, sl, sq, sr, sv, sv-SE, sw, ta, ' \
'th, tl, tr, ug, uk, ur, uz, vi, zh-CN, zh-HK, zh-TW'.split(',').each do |loc|
  Rails.application.config.i18n.available_locales << loc.strip
end
