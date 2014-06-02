# -*- encoding : utf-8 -*-
require 'spec_helper'

# Force this to be a helper spec, so that we get access to helper.render
RSpec.describe MarkdownHandler, type: :helper do
  context 'with a Markdown template including ERB' do
    before(:example) do
      @path = Rails.root.join('app', 'views', 'search', 'test_spec.md')
      $spec_markdown_global = 'things'
      File.open(@path, 'w') do |file|
        file.puts('# Testing <%= $spec_markdown_global %> #')
      end
    end

    after(:example) do
      File.delete(@path)
    end

    it 'renders the Markdown as expected' do
      html = helper.render file: @path

      expect(html).to be
      expect(html).to have_selector('h1', text: 'Testing things')
    end
  end
end
