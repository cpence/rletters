require 'test_helper'
require 'pdf/inspector'

class RLetters::Visualization::WordCloudTest < ActiveSupport::TestCase
  test 'creates one page' do
    pdf_string = RLetters::Visualization::WordCloud.call(
      header: 'Test Header',
      words: { 'one' => 5, 'two' => 3, 'th&ree' => 1 },
      color: 'Reds',
      font: 'Arvo')
    page_analysis = PDF::Inspector::Page.analyze(pdf_string)

    assert_equal 1, page_analysis.pages.size
  end

  test 'outputs the header and words' do
    pdf_string = RLetters::Visualization::WordCloud.call(
      header: 'Test Header',
      words: { 'one' => 5, 'two' => 3, 'th&ree' => 1 },
      color: 'Reds',
      font: 'Arvo')
    text_analysis = PDF::Inspector::Text.analyze(pdf_string)

    assert_includes text_analysis.strings, 'Test Header'
    assert_includes text_analysis.strings, 'one'
    assert_includes text_analysis.strings, 'two'
    assert_includes text_analysis.strings, 'th&ree'
  end

  test 'uses the requested font' do
    pdf_string = RLetters::Visualization::WordCloud.call(
      header: 'Test Header',
      words: { 'one' => 5, 'two' => 3, 'th&ree' => 1 },
      color: 'Reds',
      font: 'Arvo')
    text_analysis = PDF::Inspector::Text.analyze(pdf_string)

    assert text_analysis.font_settings.any? { |s| s[:name] =~ /Arvo/ }
  end
end
