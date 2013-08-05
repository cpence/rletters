# -*- encoding : utf-8 -*-
require 'spec_helper'

describe DatasetsController do

  # The routing needed to make the different analysis task classes work is
  # complicated enough that we should test it explicitly, in case it breaks
  # in future versions of Rails.
  describe 'routing' do
    it 'routes to #task_start' do
      get('/datasets/1/task/Task/start').should route_to(
        'datasets#task_start',
        id: '1',
        class: 'Task'
      )
    end

    it "doesn't route invalid classes to start" do
      get('/datasets/1/task/asdf/start').should_not be_routable
    end

    it 'routes to #task_view' do
      get('/datasets/1/task/2/view/show').should route_to(
        'datasets#task_view',
        id: '1',
        task_id: '2',
        view: 'show'
      )
    end

    it "doesn't route invalid task IDs to show" do
      get('/datasets/1/task/NotID/view/show').should_not be_routable
    end

    it 'routes with formats to #task_view' do
      get('/datasets/1/task/2/view/show.csv').should route_to(
        'datasets#task_view',
        id: '1',
        task_id: '2',
        view: 'show',
        format: 'csv'
      )
    end

    it 'routes to #task_destroy' do
      get('/datasets/1/task/2/destroy').should route_to(
        'datasets#task_destroy',
        id: '1',
        task_id: '2'
      )
    end

    it "doesn't route invalid task IDs to destroy" do
      get('/datasets/1/task/wut/destroy').should_not be_routable
    end

    it 'routes to #task_download' do
      get('/datasets/1/task/2/download').should route_to(
        'datasets#task_download',
        id: '1',
        task_id: '2'
      )
    end

    it "doesn't route invalid task IDs to download" do
      get('/datasets/1/task/wut/download').should_not be_routable
    end
  end

end
