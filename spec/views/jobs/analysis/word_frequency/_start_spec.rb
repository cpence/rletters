# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'word_frequency/_start' do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:dataset)
  end

  it 'has a link to the parameters page' do
    render

    link = url_for(controller: 'datasets',
                   action: 'task_view',
                   view: 'params',
                   class: 'WordFrequency',
                   id: @dataset.to_param)

    expect(rendered).to have_tag("a[href='#{link}']")
  end

end
