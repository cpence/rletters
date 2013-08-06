# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'jobs/export_citations/start' do

  before(:each) do
    # RSpec isn't smart enough to read our routes for us, so set
    # things manually here.
    controller.controller_path = 'datasets'
    controller.request.path_parameters[:controller] = 'datasets'

    @dataset = FactoryGirl.create(:dataset)
  end

  it 'has a link to the parameters page' do
    render

    link = url_for(controller: 'datasets',
                   action: 'task_view',
                   class: 'ExportCitations',
                   id: @dataset.to_param,
                   view: 'params')
    rendered.should have_tag("a[href='#{link}']")
  end

end
