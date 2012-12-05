# -*- encoding : utf-8 -*-

# Set the list of available locales ('en' ships with Rails)
APP_CONFIG['available_locales'] = ['en']

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
# - csb (Kashubian, not in CLDR at all)
# - dsb (Lower Sorbian, not in CLDR at all)
# - fur (Friulian, CLDR is missing languages and territories, still in draft)
# - hsb (Upper Sorbian, not in CLDR at all)
# - mn (or mon, Mongolian, not in CLDR at all)
# - scr (obsolete for Serbo-Croatian, not in CLDR at all)
# - tl (or tgl, Tagalog, not in CLDR at all)
# - wo (or wol, Wolof, not in CLDR at all)
"ar, az, bg, bn-IN, bs, ca, cs, cy, da, de, de-AT, de-CH, el, en-AU, en-CA, " \
"en-GB, en-IN, en-US, eo, es, es-AR, es-CL, es-CO, es-419, es-MX, es-PE, " \
"es-VE, et, eu, fa, fi, fr, fr-CA, fr-CH, gl-ES, gsw-CH, he, hi, hi-IN, hr, " \
"hu, id, is, it, ja, kn, ko, lo, lt, lv, mk, nb, ne, nl, nn, pl, pt-BR, " \
"pt-PT, rm, ro, ru, sk, sl, sr, sv-SE, sw, th, tr, uk, uz, vi, zh-CN, " \
"zh-TW".split(',').each do |loc|
  APP_CONFIG['available_locales'] << loc.strip
end
