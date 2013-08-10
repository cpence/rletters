# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersHelper do

  describe '#options_from_locales' do
    it 'includes options for locales without country codes' do
      expect(helper.options_from_locales).to have_tag('option[value=az]', text: 'Azeri')
    end

    it 'includes options for locales with country codes' do
      expect(helper.options_from_locales).to have_tag('option[value=es-MX]', text: 'Spanish (Mexico)')
    end
  end

  describe '#get_user_language' do
    context 'with no ACCEPT_LANGUAGE' do
      it 'returns the default locale' do
        expect(helper.get_user_language).to eq('en')
      end
    end

    context 'when ACCEPT_LANGUAGE has a country code' do
      it 'parses correctly' do
        allow(controller.request).to receive(:env).and_return({ 'HTTP_ACCEPT_LANGUAGE' => 'es-mx,es;q=0.5' })
        expect(helper.get_user_language).to eq('es-MX')
      end
    end

    context 'when ACCEPT_LANGUAGE does not have a country code' do
      it 'parses correctly' do
        allow(controller.request).to receive(:env).and_return({ 'HTTP_ACCEPT_LANGUAGE' => 'es' })
        expect(helper.get_user_language).to eq('es')
      end
    end
  end

  describe '#options_from_timezones' do
    it 'includes an option for some common time zones' do
      ret = helper.options_from_timezones
      expect(ret).to have_tag('option[value="Mountain Time (US & Canada)"]', text: '(GMT-07:00) Mountain Time (US & Canada)')
      expect(ret).to have_tag('option[value="West Central Africa"]', text: '(GMT+01:00) West Central Africa')
    end
  end

end
