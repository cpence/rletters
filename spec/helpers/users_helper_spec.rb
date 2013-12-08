# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersHelper do

  describe '#available_locales' do
    it 'includes locales without country codes' do
      expect(helper.available_locales).to include(%w(az Azeri))
    end

    it 'includes options for locales with country codes' do
      expect(helper.available_locales).to include(%w(es-MX Spanish\ (Mexico)))
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
        allow(controller.request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => 'es-mx,es;q=0.5')
        expect(helper.get_user_language).to eq('es-MX')
      end
    end

    context 'when ACCEPT_LANGUAGE does not have a country code' do
      it 'parses correctly' do
        allow(controller.request).to receive(:env).and_return('HTTP_ACCEPT_LANGUAGE' => 'es')
        expect(helper.get_user_language).to eq('es')
      end
    end
  end

end
