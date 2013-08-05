# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'search/advanced' do

  before(:each) do
    render
  end

  describe 'guided search form' do
    it 'has a fulltext box' do
      rendered.should have_tag('input#fulltext')
    end

    it 'has fulltext type buttons' do
      rendered.should have_tag('input#fulltext_type_exact')
      rendered.should have_tag('input#fulltext_type_fuzzy')
    end

    it 'has an authors box' do
      rendered.should have_tag('input#authors')
    end

    it 'has a title box' do
      rendered.should have_tag('input#title')
    end

    it 'has title type buttons' do
      rendered.should have_tag('input#title_type_exact')
      rendered.should have_tag('input#title_type_fuzzy')
    end

    it 'has a journal box' do
      rendered.should have_tag('input#journal')
    end

    it 'has journal type buttons' do
      rendered.should have_tag('input#journal_type_exact')
      rendered.should have_tag('input#journal_type_fuzzy')
    end

    it 'has a year range box' do
      rendered.should have_tag('input#year_ranges')
    end

    it 'has a volume box' do
      rendered.should have_tag('input#volume')
    end

    it 'has a number box' do
      rendered.should have_tag('input#number')
    end

    it 'has a pages box' do
      rendered.should have_tag('input#pages')
    end
  end

  describe 'Solr search form' do
    it 'has a Solr query box' do
      rendered.should have_tag('textarea#q')
    end
  end

  it 'has two forms that submit to the right place' do
    rendered.should have_tag("form[action='#{search_path}'][method=get]", count: 2)
  end

end
