# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:helpers' if defined?(SimpleCov)

# We need to run a variety of tests that have access to a helper context (e.g.,
# to test core_ext patches), but we don't actually *have* an application
# helper. Just define something right here for the purpose of testing.
#module ApplicationHelper; end

describe ApplicationHelper do
  # This is a test for I18n.translate_markdown and its associated helper patch,
  # lib/core_ext/i18n/translate_markdown.rb
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
      before(:all) do
        I18n.backend.store_translations(
          :en,
          workflow: { spectest: { testing: '# Testing #' } }
        )

        @custom_filename = Rails.root.join('app', 'views', 'workflow', 'spectest.html.haml')
        File.open(@custom_filename, 'w') do |f|
          f.write('= translate_markdown(".testing")')
        end
      end

      after(:all) do
        File.delete(@custom_filename)
      end

      it 'renders Markdown in translations' do
        render template: 'workflow/spectest'
        expect(rendered).to have_selector('h1', text: 'Testing')
      end
    end
  end

  describe '#render_localized_markdown' do
    context 'with a locale that exists' do
      before(:each) do
        I18n.locale = :en
      end

      it 'renders the file' do
        path = Rails.root.join('config', 'locales', 'plot_dates', 'plot_dates.en.md')
        expect(helper).to receive(:render).with(file: path).and_return('')
        helper.render_localized_markdown(:plot_dates)
      end
    end

    context 'with a missing locale' do
      before(:each) do
        I18n.locale = :az
      end

      after(:each) do
        I18n.locale = :en
      end

      it 'falls back to English' do
        path = Rails.root.join('config', 'locales', 'plot_dates', 'plot_dates.en.md')
        expect(helper).to receive(:render).with(file: path).and_return('')
        helper.render_localized_markdown(:plot_dates)
      end
    end

    context 'with a missing file' do
      it 'raises MissingTranslationData' do
        expect {
          helper.render_localized_markdown(:not_there)
        }.to raise_error(I18n::MissingTranslationData)
      end
    end
  end

  describe '#render_job_partial' do
    context 'with a partial that is present' do
      before(:all) do
        @path = Rails.root.join('lib', 'jobs', 'analysis', 'views',
                                'plot_dates', '_test_spec.html.haml').to_s

        File.open(@path, 'w') do |f|
          f.puts '%h1 Testing'
        end
      end

      after(:all) do
        File.unlink(@path)
      end

      it 'succeeds' do
        expect(helper).to receive(:render).with(file: @path, locals: { klass: Jobs::Analysis::PlotDates }).and_return('')
        helper.render_job_partial(Jobs::Analysis::PlotDates, 'test_spec')
      end
    end

    context 'with a non-HAML partial' do
      before(:all) do
        @path = Rails.root.join('lib', 'jobs', 'analysis', 'views',
                                'plot_dates', '_test_spec.html.md').to_s

        File.open(@path, 'w') do |f|
          f.puts '# Testing'
        end
      end

      after(:all) do
        File.unlink(@path)
      end

      it 'succeeds' do
        expect(helper).to receive(:render).with(file: @path, locals: { klass: Jobs::Analysis::PlotDates }).and_return('')
        helper.render_job_partial(Jobs::Analysis::PlotDates, 'test_spec')
      end
    end

    context 'with a missing partial' do
      it 'raises an exception' do
        expect {
          helper.render_job_partial(Jobs::Analysis::PlotDates, 'notapartial')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#render_flash' do
    # Very strange, but we have to do this to get html_escape() to work in the
    # helper.
    include ERB::Util

    before(:each) do
      flash[:alert] = 'alert test'
      flash[:other] = 'generic test'

      @html = render_flash
    end

    it 'renders custom classes' do
      expect(@html).to have_selector('div.flash-alert', text: 'alert test')
    end

    it 'renders generic classes' do
      expect(@html).to have_selector('div.flash-generic', text: 'generic test')
    end
  end

end
