# -*- encoding : utf-8 -*-

# Set the list of available locales ('en' ships with Rails)
RLetters::Application.config.i18n.available_locales = ['en']

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
# - wo (or wol, Wolof, not in CLDR at all)
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
"af, ar, az, bg, bn, bs, ca, cs, cy, da, de, de-AT, de-CH, el, en-AU, " \
"en-CA, en-GB, en-IN, en-NZ, en-IE, eo, es, es-419, es-AR, es-CL, es-CO, " \
"es-MX, es-PE, es-VE, et, eu, fa, fi, fr, fr-CA, fr-CH, gl, he, hi, hi-IN, " \
"hr, hu, id, is, it, it-CH, ja, kn, ko, lo, lt, lv, mk, mn, nb, ne, nl, nn, " \
"or, pl, pt, pt-BR, rm, ro, ru, sk, sl, sr, sv, sw, th, tr, uk, uz, vi, " \
"zh-CN, zh-HK, zh-TW".split(',').each do |loc|
  RLetters::Application.config.i18n.available_locales << loc.strip
end
