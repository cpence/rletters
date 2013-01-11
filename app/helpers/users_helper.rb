# -*- encoding : utf-8 -*-

# Markup generators for the users controller
module UsersHelper
  # Create a localized list of languages
  #
  # This method uses the translated languages and territories lists from the
  # CLDR to create a set of option tags, one per each available locale
  # (similar to +options_from_collection+ in Rails) that can be placed inside
  # a select element.  The locale specified in +current+ will be selected.
  #
  # @api public
  # @param [String] current the current locale, gets +selected+ attribute
  # @return [String] set of localized locale options tags
  # @example Create a select box for the locale
  #   <select name='locale'><%= options_from_locales(user.locale) %></select>
  def options_from_locales(current = I18n.locale)
    list = []

    Rails.application.config.i18n.available_locales.each do |loc|
      parts = loc.split('-')
      entry = ''

      if parts.count == 1
        # Just a language, translate
        entry = I18n.t("languages.#{loc}")
      elsif parts.count == 2
        # A language and a territory
        entry = I18n.t("languages.#{parts[0]}")
        entry += " ("
        entry += I18n.t("territories.#{parts[1]}")
        entry += ")"
      end

      list << [entry, loc]
    end

    list.sort! { |a, b| a[0] <=> b[0] }
    options_for_select(list, current)
  end

  # Get the user's preferred language from the Accept-Language header
  #
  # @api public
  # @return [String] the preferred language specified by the browser
  # @example Set the user's default language by the Accept-Language header
  #   user.locale = get_user_language
  def get_user_language
    acc_language = request.env['HTTP_ACCEPT_LANGUAGE']
    if acc_language
      lang = acc_language.scan(/^([a-z]{2,3}(-[A-Za-z]{2})?)/u).first[0]
      if lang.include? '-'
        # Capitalize the country portion (many browsers send it lowercase)
        lang[-2, 2] = lang[-2, 2].upcase
        lang
      else
        lang
      end
    else
      I18n.default_locale.to_s
    end
  end
  
  # Create a list of all timezones
  #
  # This function returns a set of option tags for every timezone (similar
  # to +options_from_collection+ in Rails), which can be put inside a select
  # item.
  #
  # @api public
  # @param [String] current the currently selected timezone
  # @return [String] set of timezone option tags
  # @example Create a select box for the timezone
  #   <select name='timezone'><%= options_from_timezones(user.timezone) %></select>
  def options_from_timezones(current = '')
    options_for_select(ActiveSupport::TimeZone.all.map { |tz| [tz.to_s, tz.name]}, current)
  end
end

