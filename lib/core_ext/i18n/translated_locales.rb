
# We only want to run this patch once, after we're done with setting up
# all the locales in the initializer
RLetters::Application.config.after_initialize do
  locales = I18n.available_locales

  # Open up the I18n.available_locales object and add a method to it that
  # returns translated strings suitable for use with simple_form
  def locales.translated
    sort.map do |loc|
      parts = loc.to_s.split('-')

      # Language, optionally with a territory as well
      name = I18n.t("languages.#{parts[0]}")
      name += " (#{I18n.t("territories.#{parts[1]}")})" if parts.size == 2

      [name, loc.to_s]
    end
  end
end
