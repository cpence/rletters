require 'test_helper'

class Admin::MarkdownPageTest < ActiveSupport::TestCase
  test 'should be invalid without name' do
    page = build_stubbed(:markdown_page, name: nil)

    refute page.valid?
  end

  test 'should be valid with name' do
    page = build_stubbed(:markdown_page)

    assert page.valid?
  end

  test 'should return translated friendly_name' do
    # There's no way to *delete* a translation from the I18n backend, so
    # we have to do this in one test to make sure they're in order
    page = build_stubbed(:markdown_page)

    assert_equal page.name, page.friendly_name

    I18n.backend.store_translations :en, markdown_pages:
      { page.name.to_sym => 'The Friendly Name' }
    assert_equal 'The Friendly Name', page.friendly_name
  end

  test 'should return empty string when rendering invalid page' do
    assert_equal '', Admin::MarkdownPage.render('not_a_page_id')
  end

  test 'should return rendered markdown' do
    page = create(:markdown_page)

    assert_includes Admin::MarkdownPage.render(page.name), '<h1 id="header">Header</h1>'
  end
end
