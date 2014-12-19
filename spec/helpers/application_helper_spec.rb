# -*- encoding : utf-8 -*-
require 'spec_helper'

# We need to run a variety of tests that have access to a helper context (e.g.,
# to test core_ext patches), but we don't actually *have* an application
# helper. Just define something right here for the purpose of testing.
module ApplicationHelper; end

RSpec.describe ApplicationHelper, type: :helper do
  # This is a test for I18n.translate_markdown and its associated helper patch,
  # lib/core_ext/i18n/translate_markdown.rb
  #
  # FIXME: Is this really the only way to test this?
  describe '#translate_markdown' do
    context 'without a shortcut' do
      it 'renders Markdown in translations' do
        I18n.backend.store_translations :en, test_markdown: '# Testing %{word} #'

        html = helper.translate_markdown(:test_markdown, word: 'things')
        expect(html).to be
        expect(html).to have_selector('h1', text: 'Testing things')
      end

      it 'works when called as t_md' do
        I18n.backend.store_translations :en, test_markdown: '# Testing %{word} #'

        html = helper.t_md(:test_markdown, word: 'things')
        expect(html).to be
        expect(html).to have_selector('h1', text: 'Testing things')
      end
    end

    context 'with a shortcut' do
      before(:context) do
        I18n.backend.store_translations(
          :en,
          workflow: { spectest: { testing: '# Testing #' } }
        )

        @custom_filename = Rails.root.join('app', 'views', 'workflow', 'spectest.html.haml')
        File.open(@custom_filename, 'w') do |f|
          f.write('= translate_markdown(".testing")')
        end
      end

      after(:context) do
        File.delete(@custom_filename)
      end

      it 'renders Markdown in translations' do
        render template: 'workflow/spectest'
        expect(rendered).to have_selector('h1', text: 'Testing')
      end
    end
  end
end
