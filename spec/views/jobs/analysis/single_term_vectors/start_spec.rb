# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'jobs/single_term_vectors/start' do

  before(:each) do
    # RSpec isn't smart enough to read our routes for us, so set
    # things manually here.
    controller.controller_path = 'datasets'
    controller.request.path_parameters[:controller] = 'datasets'
  end

  context 'when dataset has one document' do
    before(:each) do
      @dataset = FactoryGirl.create(:full_dataset, entries_count: 1)
    end

    it 'has a link to start the task' do
      render

      link = url_for(controller: 'datasets',
                     action: 'task_start',
                     class: 'SingleTermVectors',
                     id: @dataset.to_param)
      expect(rendered).to have_tag("a[href='#{link}']")
    end
  end

  context 'when dataset has more than one document' do
    before(:each) do
      @dataset = FactoryGirl.create(:full_dataset)
    end

    it 'does not have a link to start the task' do
      render
      expect(rendered).not_to have_tag('a')
    end
  end

end
