# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe I18n do
  describe '#available_locales' do
    describe '#translated' do
      it 'includes locales without country codes' do
        expect(I18n.available_locales.translated).to include(%w(Azeri az))
      end

      it 'includes options for locales with country codes' do
        expect(I18n.available_locales.translated).to include(%w(Spanish\ (Mexico) es-MX))
      end
    end
  end
end
