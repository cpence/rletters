# Enable pluralization and language fallbacks (from 'de-DE' to 'de')
require 'i18n/backend/fallbacks'
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
require 'i18n/backend/pluralization'
I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

# Raise errors if we try to use a locale that isn't available
I18n.config.enforce_available_locales = true

# Default to English
Rails.application.config.i18n.default_locale = :en
Rails.application.config.i18n.available_locales = []

# Always use the fallbacks
Rails.application.config.i18n.fallbacks = true

# This exact line is taken from the README file of the rails-i18n gem, which
# supplies localizations for all our Rails defaults. Just paste it in when you
# update the version of rails-i18n and the rest will be automatic here.
'af, ar, az, be, bg, bn, bs, ca, cs, cy, da, de, de-AT, de-CH, de-DE, el, el-CY, en, en-AU, en-CA, en-GB, en-IE, en-IN, en-NZ, en-US, en-ZA, en-CY,eo, es, es-419, es-AR, es-CL, es-CO, es-CR, es-EC, es-ES, es-MX, es-NI, es-PA, es-PE, es-US, es-VE, et, eu, fa, fi, fr, fr-CA, fr-CH, fr-FR, gl, he, hi, hi-IN, hr, hu, id, is, it, it-CH, ja, ka, km, kn, ko, lb, lo, lt, lv, mk, ml, mn, mr-IN, ms, nb, ne, nl, nn, oc, or, pa, pl, pt, pt-BR, rm, ro, ru, sk, sl, sq, sr, sw, ta, th, tl, tr, tt, ug, ur, uz, vi, wo, zh-CN, zh-HK, zh-TW, zh-YUE'.split(',').each do |loc|
  loc.strip!
  next unless TwitterCldr.supported_locale?(loc.downcase)

  Rails.application.config.i18n.available_locales << loc
end
