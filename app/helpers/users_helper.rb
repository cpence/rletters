# -*- encoding : utf-8 -*-

# Markup generators for the users controller
module UsersHelper
  # Create a localized list of languages
  #
  # This method uses the translated languages and territories lists from the
  # CLDR to create a collection for use with simple_form.
  #
  # @api public
  # @return [Array<Hash>] set of localized locale options tags
  # @example Create a select box for the locale
  #   <%= f.input :language, collection: available_locales %>
  def available_locales
    list = []

    Rails.application.config.i18n.available_locales.each do |loc|
      parts = loc.split('-')
      entry = ''

      if parts.count == 1
        # Just a language, translate
        name = I18n.t("languages.#{loc}")
      elsif parts.count == 2
        # A language and a territory
        name = I18n.t("languages.#{parts[0]}")
        name += ' ('
        name += I18n.t("territories.#{parts[1]}")
        name += ')'
      end

      list << [ loc, name ]
    end

    list.sort! { |a, b| a.first <=> b.first }
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
      lang = acc_language.scan(/^([a-z]{2,3}(-[A-Za-z]{2})?)/).first[0]
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
end

