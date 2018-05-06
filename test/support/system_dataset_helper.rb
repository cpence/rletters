# frozen_string_literal: true

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
end
