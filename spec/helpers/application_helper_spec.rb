# -*- encoding : utf-8 -*-
require 'spec_helper'

SimpleCov.command_name 'spec:helpers' if defined?(SimpleCov)

describe ApplicationHelper do

  describe '#render_footer_list' do
    # FIXME: Can't decide whether or not we want to test this.
  end

  describe '#t_md' do
    context "without a shortcut" do
      it "should render Markdown in translations" do
        I18n.backend.store_translations :en, test_markdown: '# Testing #'

        html = helper.t_md(:test_markdown)
        html.should be
        html.should have_tag('h1', text: 'Testing')
      end
    end

    context "with a shortcut" do
      before(:all) do
        I18n.backend.store_translations :en, info: { spectest: { testing: '# Testing #' }}

        @custom_filename = Rails.root.join('app', 'views', 'info', 'spectest.html.haml')
        File.open(@custom_filename, 'w') do |f|
          f.write('= t_md(".testing")')
        end
      end

      after(:all) do
        File.delete(@custom_filename)
      end

      it "should render Markdown in translations" do
        render template: 'info/spectest'
        rendered.should have_tag('h1', text: 'Testing')
      end
    end
  end

end
