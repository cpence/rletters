require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
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
