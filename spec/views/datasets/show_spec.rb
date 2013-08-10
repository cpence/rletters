# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'datasets/show' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    @dataset = FactoryGirl.create(:full_dataset, entries_count: 10)
    assign(:dataset, @dataset)
    params[:id] = @dataset.to_param
  end

  it 'shows the number of dataset entries' do
    render
    expect(rendered).to match(/Number of documents: 10/)
  end

  it 'shows the create-task placeholder' do
    # The list of tasks to create is brought in by AJAX, so it won't be there
    # in the test environment.
    render
    expect(rendered).to match(/Loading analysis tasks/)
  end

  it 'has a reference somewhere to the task list' do
    # Need to render the layout in order to get the page-JS
    render template: 'datasets/show', layout: 'layouts/application'
    expect(rendered).to include(task_list_dataset_path(@dataset))
  end

end
