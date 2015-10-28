require 'rails_helper'
require 'pdf/inspector'

RSpec.describe RLetters::Visualization::WordCloud do
  describe '#call' do
    before(:context) do
      # Test a word with an XML special character in it
      words = { 'one' => 5, 'two' => 3, 'th&ree' => 1 }

      @pdf_string = described_class.call(
        header: 'Test Header',
        words: words,
        color: 'Reds',
        font: 'Arvo')
      @text_analysis = PDF::Inspector::Text.analyze(@pdf_string)
      @page_analysis = PDF::Inspector::Page.analyze(@pdf_string)
    end

    it 'makes one page' do
      expect(@page_analysis.pages.size).to eq(1)
    end

    it 'outputs the header' do
      expect(@text_analysis.strings).to include('Test Header')
    end

    it 'uses the font' do
      expect(@text_analysis.font_settings.map { |h| h[:name] }).to be_any { |s| s =~ /Arvo/ }
    end

    it 'lists all of the words' do
      expect(@text_analysis.strings).to include('one')
      expect(@text_analysis.strings).to include('two')
      expect(@text_analysis.strings).to include('th&ree')
    end
  end
end
