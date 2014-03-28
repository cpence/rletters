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
end
