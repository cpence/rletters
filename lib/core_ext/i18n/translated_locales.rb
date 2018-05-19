# frozen_string_literal: true

module I18n
  # Translate an individual locale string
  #
  # We're adding a method to the I18n.locales object that will translate a
  # given locale into the currently active language.
  #
  # @param [Symbol] loc the locale to translate
  # @return [String] the language (and possibly region), translated into the
  #   current language
  def self.translate_locale(locale)
    loc = locale.to_s.downcase.tr('_', '-')

    cur_locale = TwitterCldr::Shared::Locale.parse(I18n.locale.downcase)
    cur_lang = cur_locale.language

    ret = TwitterCldr::Shared::Languages.from_code_for_locale(loc, cur_lang).dup

    if ret.nil?
      # If that didn't work, parse it and try to do it ourselves
      parsed = TwitterCldr::Shared::Locale.parse(loc)
      ret = TwitterCldr::Shared::Languages.from_code_for_locale(
        parsed.language,
        cur_lang
      ).dup
      raise "Cannot translate #{locale} into #{I18n.locale}" unless ret

      # See if there's a region we should try to add
      if parsed.region
        reg = TwitterCldr::Shared::Territories.from_territory_code_for_locale(
          parsed.region,
          cur_lang
        ).dup

        # Just use the code if there's no translation
        reg ||= parsed.region

        ret << " (#{reg})"
      end
    end

    ret
  end

  # Format the available locales, translated, for Rails's options array
  #
  # @return [Array<Array<String, String>>] each locale's translation and
  #   language code
  def self.locale_options_array
    I18n.available_locales.sort.map do |loc|
      [I18n.translate_locale(loc), loc.to_s]
    end
  end
end
