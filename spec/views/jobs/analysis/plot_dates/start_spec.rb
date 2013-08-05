# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'jobs/plot_dates/start' do

  before(:each) do
    # RSpec isn't smart enough to read our routes for us, so set
    # things manually here.
    controller.controller_path = 'datasets'
    controller.request.path_parameters[:controller] = 'datasets'

    @dataset = FactoryGirl.create(:dataset)
  end

  it 'has a link to start the task' do
    render

    link = url_for(controller: 'datasets',
                   action: 'task_start',
                   class: 'PlotDates',
                   id: @dataset.to_param)

    rendered.should have_tag("a[href='#{link}']")
  end

end
