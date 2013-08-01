# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UsersHelper do

  describe '#options_from_locales' do
    it 'includes options for locales without country codes' do
      helper.options_from_locales.should have_tag('option[value=az]', :text => "Azeri")
    end

    it 'includes options for locales with country codes' do
      helper.options_from_locales.should have_tag('option[value=es-MX]', :text => "Spanish (Mexico)")
    end
  end

  describe '#get_user_language' do
    context 'when ACCEPT_LANGUAGE has a country code' do
      it 'parses correctly' do
        controller.request.stub(:env) { { 'HTTP_ACCEPT_LANGUAGE' => 'es-mx,es;q=0.5' } }
        helper.get_user_language.should eq('es-MX')
      end
    end

    context 'when ACCEPT_LANGUAGE does not have a country code' do
      it 'parses correctly' do
        controller.request.stub(:env) { { 'HTTP_ACCEPT_LANGUAGE' => 'es' } }
        helper.get_user_language.should eq('es')
      end
    end
  end

  describe '#options_from_timezones' do
    it 'includes an option for some common time zones' do
      ret = helper.options_from_timezones
      ret.should have_tag('option[value="Mountain Time (US & Canada)"]', :text => "(GMT-07:00) Mountain Time (US & Canada)")
      ret.should have_tag('option[value="West Central Africa"]', :text => "(GMT+01:00) West Central Africa")
    end
  end

end
