require 'application_system_test_case'

class CookieWarningTest < ApplicationSystemTestCase
  test 'rejecting cookie warning works' do
    visit '/'
    click_button 'I disagree'

    visit '/'
    assert_text 'I agree'
    assert_text 'I disagree'
  end

  test 'declining cookie warning hides remember me' do
    visit '/'
    click_button 'I disagree'

    click_link 'Sign In'
    assert_no_text 'Remember me'
  end

  test 'accepting cookie warning works' do
    visit '/'
    click_button 'I agree'

    visit '/'
    assert_no_text 'I agree'
    assert_no_text 'I disagree'
  end

  test 'accepting cookie warning shows remember me' do
    visit '/'
    click_button 'I agree'

    click_link 'Sign In'
    assert_text 'Remember me'
  end
end
