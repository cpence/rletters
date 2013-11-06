
def create_visitor
  @visitor ||=
    { name: 'Testy McUserton',
      email: 'example@example.com',
      password: 'changeme',
      password_confirmation: 'changeme' }
end

def find_user
  @user ||= User.where(email: @visitor[:email]).first
end

def create_user
  create_visitor
  delete_user
  @user = FactoryGirl.create(:user, @visitor)
end

def delete_user
  @user ||= User.where(email: @visitor[:email]).first
  @user.destroy if @user
end

def sign_up
  delete_user
  visit '/users/sign_up'
  # The first instance of user_email and user_password is in the 'Sign In'
  # menu at the top of the page, so we have to find the main form manually.
  within('.main') do
    fill_in 'user_name', with: @visitor[:name]
    fill_in 'user_email', with: @visitor[:email]
    fill_in 'user_password', with: @visitor[:password]
    fill_in 'user_password_confirmation',
            with: @visitor[:password_confirmation]
  end
  click_button 'Sign up'
  find_user
end

def sign_in
  visit '/'
  fill_in 'user_email', with: @visitor[:email]
  fill_in 'user_password', with: @visitor[:password]
  click_button 'Sign in'
end

### GIVEN ###
Given /^I am not logged in$/ do
  visit '/users/sign_out'
end

Given /^I am logged in$/ do
  create_user
  sign_in
end

Given /^I exist as a user$/ do
  create_user
end

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

### WHEN ###
When /^I sign in with valid credentials$/ do
  create_visitor
  sign_in
end

When /^I sign out$/ do
  visit '/users/sign_out'
end

When /^I sign up with valid user data$/ do
  create_visitor
  sign_up
end

When /^I sign up with an invalid email$/ do
  create_visitor
  @visitor = @visitor.merge(email: 'notanemail')
  sign_up
end

When /^I sign up without a password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(password_confirmation: '')
  sign_up
end

When /^I sign up without a password$/ do
  create_visitor
  @visitor = @visitor.merge(password: '')
  sign_up
end

When /^I sign up with a mismatched password confirmation$/ do
  create_visitor
  @visitor = @visitor.merge(password_confirmation: 'changeme123')
  sign_up
end

When /^I return to the site$/ do
  visit '/'
end

When /^I sign in with a wrong email$/ do
  @visitor = @visitor.merge(email: 'wrong@example.com')
  sign_in
end

When /^I sign in with a wrong password$/ do
  @visitor = @visitor.merge(password: 'wrongpass')
  sign_in
end

When /^I edit my account details$/ do
  within('nav') { click_link 'My Account' }
  fill_in 'user_email', with: 'new@example.com'
  fill_in 'user_current_password', with: @visitor[:password]
  click_button 'Update settings'
end

When /^I look at the list of users$/ do
  visit '/'
end

### THEN ###
Then /^I should be signed in$/ do
  expect(page).to have_content('Sign Out')
  expect(page).not_to have_content('Sign In')
end

Then /^I should be signed out$/ do
  expect(page).to have_content('Sign In')
  expect(page).not_to have_content('Sign Out')
end

Then /^I see a successful sign in message$/ do
  expect(page).to have_content('Signed in successfully.')
end

Then /^I should see a successful sign up message$/ do
  expect(page).to have_content('Welcome! You have signed up successfully.')
end

Then /^I should see an invalid email message$/ do
  expect(page).to have_selector('.user_email.error')
end

Then /^I should see a missing password message$/ do
  expect(page).to have_selector('.user_password.error')
end

Then /^I should see a missing password confirmation message$/ do
  expect(page).to have_selector('.user_password_confirmation.error')
end

Then /^I should see a mismatched password message$/ do
  expect(page).to have_selector('.user_password_confirmation.error small',
                                text: "doesn't match Password")
end

Then /^I should see a signed out message$/ do
  expect(page).to have_content('Signed out successfully.')
end

Then /^I see an invalid login message$/ do
  expect(page).to have_content('Invalid email or password.')
end

Then /^I should see an account edited message$/ do
  expect(page).to have_content('You updated your account successfully.')
end
