# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'export_citations/_start' do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:dataset)
  end

  it 'has a link to the parameters page' do
    render

    link = url_for(controller: 'datasets',
                   action: 'task_view',
                   class: 'ExportCitations',
                   id: @dataset.to_param,
                   view: 'params')
    expect(rendered).to have_tag("a[href='#{link}']")
  end

end
