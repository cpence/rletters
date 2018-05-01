require 'test_helper'

class Admin::SnippetTest < ActiveSupport::TestCase
  test 'should be invalid without name' do
    snippet = build_stubbed(:snippet, name: nil)

    refute snippet.valid?
  end

  test 'should be invalid without language' do
    snippet = build_stubbed(:snippet, language: nil)

    refute snippet.valid?
  end

  test 'should be valid with name and language' do
    snippet = build_stubbed(:snippet)

    assert snippet.valid?
  end

  test 'should be invalid if duplicating name and language' do
    source = create(:snippet)

    snippet = build_stubbed(:snippet, name: source.name, language: source.language)
    refute snippet.valid?
  end

  test 'should be valid if duplicating language with different name' do
    source = create(:snippet)

    snippet = build_stubbed(:snippet, name: 'different_name_time', language: source.language)
    assert snippet.valid?
  end

  test 'should return translated friendly_name' do
    # There's no way to *delete* a translation from the I18n backend, so
    # we have to do this in one test to make sure they're in order
    snippet = build_stubbed(:snippet)

    assert_equal snippet.name, snippet.friendly_name

    I18n.backend.store_translations :en, snippets:
      { snippet.name.to_sym => 'The Friendly Name' }
    assert_equal 'The Friendly Name', snippet.friendly_name
  end

  test 'should return empty string when rendering invalid snippet' do
    assert_equal '', Admin::Snippet.render('not_a_snippet_id')
  end

  test 'should return rendered markdown' do
    snippet = create(:snippet)

    assert_includes Admin::Snippet.render(snippet.name, snippet.language), '<h1 id="header">Header</h1>'
  end

  test 'should render snippets in current locale by default' do
    snippet = create(:snippet, language: :vi, content: '# WHOA')
    create(:snippet, name: snippet.name, language: :en, content: 'not this one')

    begin
      I18n.locale = :vi
      assert_includes Admin::Snippet.render(snippet.name), '<h1 id="whoa">WHOA</h1>'
    ensure
      I18n.locale = :en
    end
  end
end
