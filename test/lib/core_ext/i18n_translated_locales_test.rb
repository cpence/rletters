require 'test_helper'

class I18nTranslatedLocalesTest < ActiveSupport::TestCase
  test 'available_locales.translated works without country codes' do
    assert_includes I18n.available_locales.translated, %w(Azeri az)
  end

  test 'available_locales.translated works with country codes' do
    assert_includes I18n.available_locales.translated,
      %w(Spanish\ (Mexico) es-MX)
  end
end
