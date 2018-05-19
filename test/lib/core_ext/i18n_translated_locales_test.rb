# frozen_string_literal: true

require 'test_helper'

class I18nTranslatedLocalesTest < ActiveSupport::TestCase
  test 'translate_locale works without country codes' do
    assert_equal 'Vietnamese', I18n.translate_locale(:vi)
  end

  test 'translate_locale works with underscore country codes' do
    assert_equal 'Mexican Spanish', I18n.translate_locale(:es_MX)
  end

  test 'locale_options_array works without country codes' do
    assert_includes I18n.locale_options_array, %w[Vietnamese vi]
  end

  test 'locale_options_array works with country codes' do
    assert_includes I18n.locale_options_array, %w[Mexican\ Spanish es-MX]
  end
end
