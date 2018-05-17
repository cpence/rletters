# frozen_string_literal: true

require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'validation errors with only server error' do
    user = create(:user)
    user.stubs(:errors).returns(email: ['server error'])

    html = validation_errors_for(user, :email)
    matcher = Capybara.string(html)
    assert matcher.has_selector?('span.server-errors',
                                 text: 'server error')
  end

  test 'validation errors with only client error and no message' do
    user = create(:user)

    html = validation_errors_for(user, :email, true)
    matcher = Capybara.string(html)
    assert matcher.has_selector?('span.client-errors:not([style])',
                                 text: 'You must enter an email address')
  end

  test 'validation errors with class symbol and no message' do
    html = validation_errors_for(:user, :email, true)
    matcher = Capybara.string(html)
    assert matcher.has_selector?('span.client-errors:not([style])',
                                 text: 'You must enter an email address')
  end

  test 'validation errors with client error and message' do
    html = validation_errors_for(:user, :email, true, 'message thing')
    matcher = Capybara.string(html)
    assert matcher.has_selector?('span.client-errors:not([style])',
                                 text: 'message thing')
  end

  test 'validation errors with client and server errors' do
    user = create(:user)
    user.stubs(:errors).returns(email: ['server error'])

    html = validation_errors_for(user, :email, true)
    matcher = Capybara.string(html)

    assert matcher.has_selector?('span.server-errors',
                                 text: 'server error')
    assert matcher.has_selector?('span.client-errors',
                                 text: 'You must enter an email address',
                                 visible: false)
  end

  test 'close icon works' do
    html = close_icon(dismiss: 'modal')
    matcher = Capybara.string(html)

    assert matcher.has_selector?('button.close[data-dismiss=modal]')
  end

  # This is a test for I18n.translate_markdown and its associated helper patch,
  # lib/core_ext/i18n/translate_markdown.rb
  test 'translate_markdown without a shortcut' do
    I18n.backend.store_translations :en, test_markdown: '# Testing %{word} #'

    html = translate_markdown(:test_markdown, word: 'things')
    assert_includes html, 'Testing things</h1>'
  end

  test 't_md without a shortcut' do
    I18n.backend.store_translations :en, test_markdown: '# Testing %{word} #'

    html = t_md(:test_markdown, word: 'things')
    assert_includes html, 'Testing things</h1>'
  end

  test 'translate_markdown with a shortcut' do
    I18n.backend.store_translations(
      :en,
      workflow: { test: { testing: '# Testing #' } }
    )

    custom_filename = Rails.root.join('app', 'views', 'workflow', 'test.html.haml')
    File.open(custom_filename, 'w') do |f|
      f.write('= translate_markdown(".testing")')
    end

    render template: 'workflow/test'
    assert_select 'h1', text: 'Testing'

    File.delete(custom_filename)
  end
end
