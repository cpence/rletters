# frozen_string_literal: true

# We only want to run this patch once, after we're done with setting up
# all the locales in the initializer
RLetters::Application.config.after_initialize do
  locales = I18n.available_locales

  # Open up the I18n.available_locales object and add a method to it that
  # returns translated strings suitable for use with form helpers
  def locales.translated
    current_locale = TwitterCldr::Shared::Locale.parse(I18n.locale.downcase)
    current_lang = current_locale.language

    sort.map do |loc|
      ret = TwitterCldr::Shared::Languages.from_code_for_locale(loc.downcase,
                                                                current_lang).dup

      if ret.nil?
        # If that didn't work, parse it and try to do it ourselves
        loc = TwitterCldr::Shared::Locale.parse(loc.downcase)

        ret = TwitterCldr::Shared::Languages.from_code_for_locale(loc.language,
                                                                  current_lang).dup
        fail "Cannot translate #{loc} into #{I18n.locale}" unless ret

        # See if there's a region we should try to add
        if loc.region
          reg = TwitterCldr::Shared::Territories.from_territory_code_for_locale(loc.region,
                                                                                current_lang).dup

          # Just use the code if there's no translation
          reg ||= loc.region

          ret << " (#{reg})"
        end
      end

      [ret, loc.to_s]
    end
  end
end
