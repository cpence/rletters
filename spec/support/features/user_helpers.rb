
module Features
  module UserHelpers
    def sign_out
      visit '/users/sign_out'
    end

    def sign_up_with(params = {})
      sign_out
      params = user_params(params)
      visit '/users/sign_up'

      # The first instance of user_email and user_password is in the 'Sign In'
      # menu at the top of the page, so we have to find the main form manually.
      within('.main') do
        fill_in 'user_name', with: params[:name]
        fill_in 'user_email', with: params[:email]
        fill_in 'user_password', with: params[:password]
        fill_in 'user_password_confirmation',
                with: params[:password_confirmation]
      end

      click_button 'Sign up'
    end

    def sign_in_with(params = {}, create = true)
      params = user_params(params)
      if create
        sign_up_with(params)
        sign_out
      end

      visit '/'
      click_link 'Sign In'
      within('.dropdown-menu') do
        fill_in 'user_email', with: params[:email]
        fill_in 'user_password', with: params[:password]
        click_link 'Sign in'
      end
    end

    private

    def user_params(params)
      params ||= {}
      params[:name] ||= 'Testy McUserton'
      params[:email] ||= 'example@example.com'
      params[:password] ||= 'changeme'
      params[:password_confirmation] ||= 'changeme'
      params
    end
  end
end
