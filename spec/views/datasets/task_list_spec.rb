# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'datasets/task_list' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    @dataset = FactoryGirl.create(:full_dataset, user: @user)
    assign(:dataset, @dataset)
    params[:id] = @dataset.to_param
  end

  it 'shows pending analysis tasks' do
    FactoryGirl.create(:analysis_task, dataset: @dataset)
    render

    expect(rendered).to have_tag('li[data-theme=e]', text: '1 analysis task pending for this dataset...')
  end

  it 'is not a full document' do
    render
    expect(rendered).not_to include('</html>')
  end

  context 'with completed analysis tasks' do
    before(:each) do
      # This needs to be a real job type, since we're making URLs
      @task = FactoryGirl.create(:analysis_task,
                                 name: 'test',
                                 dataset: @dataset,
                                 job_type: 'ExportCitations',
                                 finished_at: 5.minutes.ago)
      render
    end

    it 'shows the name of the job' do
      expect(rendered).to match(/“test” Complete/)
    end

    it 'shows a link to download the results' do
      expected = url_for(controller: 'datasets',
                         action: 'task_download',
                         id: @dataset.to_param,
                         task_id: @task.to_param)
      expect(rendered).to have_tag("a[href='#{expected}']")
    end

    it 'shows a link to delete the task' do
      expected = url_for(controller: 'datasets',
                         action: 'task_destroy',
                         id: @dataset.to_param,
                         task_id: @task.to_param)
      expect(rendered).to have_tag("a[href='#{expected}']")
    end
  end

  context 'with failed analysis tasks' do
    before(:each) do
      @task = FactoryGirl.create(:analysis_task, dataset: @dataset, failed: true)
      render
    end

    it 'shows failed analysis tasks' do
      expect(rendered).to match(/1 analysis task failed for this dataset!/)
    end

    it 'shows a link to clear failed analysis tasks' do
      expect(rendered).to have_tag("a[href='#{dataset_path(@dataset, clear_failed: true)}']")
    end
  end

  context 'with all of the possible analysis task types' do
    AVAILABLE_CLASSES = %w(ExportCitations PlotDates SingleTermVectors
                           WordFrequency)

    it 'successfully renders' do
      # This is mostly just to make sure that the internals of the job classes
      # (methods like download?) work correctly
      AVAILABLE_CLASSES.each do |c|
        FactoryGirl.create(:analysis_task,
                           name: "test#{c}",
                           dataset: @dataset,
                           job_type: c,
                           finished_at: 5.minutes.ago)
      end
      render

      AVAILABLE_CLASSES.each do |c|
        expect(rendered).to match(/“test#{c}” Complete/)
      end
    end
  end

end
