
module Features
  module DatasetHelpers
    def create_dataset(params = {})
      visit search_path
      fill_in 'q', with: params[:search] || 'test'
      page.execute_script("$('form:first').submit();")

      click_link 'Save Results'
      within('.modal-dialog') do
        fill_in 'dataset_name', with: params[:name] || 'Integration Dataset'
        click_button 'Create Dataset'
      end
    end
  end
end
