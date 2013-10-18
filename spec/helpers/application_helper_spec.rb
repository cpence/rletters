# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:helpers' if defined?(SimpleCov)

describe ApplicationHelper do

  # Note that these tests are also testing our extension
  # I18n.translate_markdown, in lib/core_ext.
  describe '#translate_markdown' do
    context 'without a shortcut' do
      it 'renders Markdown in translations' do
        I18n.backend.store_translations :en, test_markdown: '# Testing #'

        html = helper.translate_markdown(:test_markdown)
        expect(html).to be
        expect(html).to have_tag('h1', text: 'Testing')
      end

      it 'works when called as t_md' do
        I18n.backend.store_translations :en, test_markdown: '# Testing #'

        html = helper.t_md(:test_markdown)
        expect(html).to be
        expect(html).to have_tag('h1', text: 'Testing')
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
        expect(rendered).to have_tag('h1', text: 'Testing')
      end
    end
  end

  describe '#render_job_partial' do
    it 'succeeds for a partial that is present' do
      expect(helper).to receive(:render).with(file: Rails.root.join('lib', 'jobs', 'analysis', 'views', 'plot_dates', '_params.html.haml').to_s).and_return('')
      helper.render_job_partial(Jobs::Analysis::PlotDates, 'params')
    end

    it 'allows rendering of non-HAML partials' do
      expect(helper).to receive(:render).with(file: Rails.root.join('lib', 'jobs', 'analysis', 'views', 'plot_dates', '_info.html.md').to_s).and_return('')
      helper.render_job_partial(Jobs::Analysis::PlotDates, 'info')
    end

    it 'renders something reasonable for missing partials' do
      output = helper.render_job_partial(Jobs::Analysis::PlotDates, 'notapartial')
      expect(output).to start_with('<p>')
    end
  end

end
