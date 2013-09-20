# -*- encoding : utf-8 -*-
require 'spec_helper'

describe NERAnalyzer,
         vcr: { cassette_name: 'solr_single_fulltext' }, nlp: true do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, entries_count: 10,
                                  working: true, user: @user)
  end

  it 'works' do
    @analyzer = NERAnalyzer.new(@dataset)
    expect(@analyzer.entity_references['PERSON']).to include('Susan G. Brown')
    expect(@analyzer.entity_references['PERSON']).to include('Amanda M. Koltz')
  end
end
