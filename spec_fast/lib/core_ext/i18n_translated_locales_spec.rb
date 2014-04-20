# -*- encoding : utf-8 -*-
require 'i18n'

def stub_available_locales
  I18n.enforce_available_locales = true
  I18n.available_locales = %w(az en es-MX)

  I18n.backend.store_translations(:en, languages: {
    az: 'Azeri',
    en: 'English',
    es: 'Spanish'
  })
  I18n.backend.store_translations(:en, territories: {
    MX: 'Mexico'
  })

  stub_const("RLetters", Module.new)
  stub_const("RLetters::Application", Class.new)
  RLetters::Application.stub(:config) do |config|
    double('config').tap do |proxy|
      proxy.stub(:after_initialize) { |&block| block.call }
    end
  end

  load 'core_ext/i18n/translated_locales.rb'
end

describe I18n do
  describe '#available_locales' do
    describe '#translated' do
      it 'includes locales without country codes' do
        stub_available_locales
        expect(I18n.available_locales.translated).to include(%w(Azeri az))
      end

      it 'includes options for locales with country codes' do
        stub_available_locales
        expect(I18n.available_locales.translated).to include(%w(Spanish\ (Mexico) es-MX))
      end
    end
  end
end
