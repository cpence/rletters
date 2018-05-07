# frozen_string_literal: true

require 'test_helper'
require 'pdf/inspector'

module RLetters
  module Visualization
    class PDFTest < ActiveSupport::TestCase
      class TestClass
        include RLetters::Visualization::PDF
      end

      test 'pdf_with_header makes one page' do
        pdf_string = TestClass.new.pdf_with_header(header: 'Test Header') { |_| }
        page_analysis = ::PDF::Inspector::Page.analyze(pdf_string)

        assert_equal 1, page_analysis.pages.size
      end

      test 'pdf_with_header outputs header and page numbers' do
        pdf_string = TestClass.new.pdf_with_header(header: 'Test Header') { |_| }
        text_analysis = ::PDF::Inspector::Text.analyze(pdf_string)

        assert_includes text_analysis.strings, 'Test Header'
        assert_includes text_analysis.strings, '1/1'
      end

      test 'pdf_with_header uses Roboto for the headers' do
        pdf_string = TestClass.new.pdf_with_header(header: 'Test Header') { |_| }
        text_analysis = ::PDF::Inspector::Text.analyze(pdf_string)

        assert text_analysis.font_settings.any? { |s| s[:name] =~ /Roboto-Regular/ }
        assert text_analysis.font_settings.any? { |s| s[:name] =~ /Roboto-Bold/ }
      end
    end
  end
end
