
module SystemDatasetHelper
  def create_dataset(params = {})
    visit search_path
    fill_in 'q', with: params[:search] || 'test'
    find('#q').send_keys(:enter)

    click_link 'Save'
    find('#modal-container .modal-content')

    within('#modal-container') do
      within('.modal-body') do
        fill_in 'dataset_name', with: params[:name] || 'Integration Dataset'
      end
      within('.modal-footer') do
        click_button 'Create Dataset'
      end
    end
  end

  def create_benchmark
    # These are to be created entirely outside the flow of the application,
    # so it's no problem that we're manually altering the database in the
    # feature specs here.
    Admin::Benchmark.create(job: 'ArticleDatesJob', size: 10, time: 10.0)
  end
end
