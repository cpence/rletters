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

    I18n.available_locales.each do |loc|
      parts = loc.to_s.split('-')
      entry = ''

      if parts.size == 1
        # Just a language, translate
        name = I18n.t("languages.#{loc}")
      elsif parts.size == 2
        # A language and a territory
        name = I18n.t("languages.#{parts[0]}")
        name += ' ('
        name += I18n.t("territories.#{parts[1]}")
        name += ')'
      end

      list << [loc.to_s, name]
    end

    list.sort! { |a, b| a.first <=> b.first }
  end
end

