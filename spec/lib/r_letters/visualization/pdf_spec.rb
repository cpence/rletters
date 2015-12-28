require 'rails_helper'
require 'pdf/inspector'

RSpec.describe RLetters::Visualization::PDF do
  let(:test_class) { Class.new { include RLetters::Visualization::PDF } }

  describe '#pdf_with_header' do
    before(:example) do
      @pdf_string = test_class.new.pdf_with_header(header: 'Test Header') { |pdf| }
      @text_analysis = PDF::Inspector::Text.analyze(@pdf_string)
      @page_analysis = PDF::Inspector::Page.analyze(@pdf_string)
    end

    it 'makes one page' do
      expect(@page_analysis.pages.size).to eq(1)
    end

    it 'outputs the header' do
      expect(@text_analysis.strings).to include('Test Header')
    end

    it 'numbers the pages' do
      expect(@text_analysis.strings).to include('1/1')
    end

    it 'uses the Roboto font' do
      expect(@text_analysis.font_settings.map { |h| h[:name] }).to be_any { |s| s =~ /Roboto-Regular/ }
      expect(@text_analysis.font_settings.map { |h| h[:name] }).to be_any { |s| s =~ /Roboto-Bold/ }
    end
  end
end
