# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'named_entities/_start', :nlp do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:dataset)
  end

  it 'has a link to the start action' do
    render

    link = url_for(controller: 'datasets',
                   action: 'task_start',
                   class: 'NamedEntities',
                   id: @dataset.to_param)
    expect(rendered).to have_tag("a[href='#{link}']")
  end

end
