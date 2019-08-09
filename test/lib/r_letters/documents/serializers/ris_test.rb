# frozen_string_literal: true

require 'test_helper'
require_relative './common_tests'

module RLetters
  module Documents
    module Serializers
      class RisTest < ActiveSupport::TestCase
        include CommonTests

        test 'single document serialization' do
          doc = build(:full_document)
          str = RLetters::Documents::Serializers::Ris.new(doc).serialize

          assert str.start_with?("TY  - JOUR\n")
          assert_includes str, 'AU  - Dickens,C.'
          assert_includes str, 'TI  - A Tale of Two Cities'
          assert_includes str, 'JO  - Actually a Novel'
          assert_includes str, 'VL  - 1'
          assert_includes str, 'IS  - 1'
          assert_includes str, 'SP  - 1'
          refute_includes str, 'EP  - '
          assert_includes str, 'PY  - 1859'
          assert str.end_with?("ER  - \n")
        end

        test 'array serialization' do
          doc = build(:full_document)
          docs = [doc, doc]
          str = RLetters::Documents::Serializers::Ris.new(docs).serialize

          assert str.start_with?("TY  - JOUR\n")
          assert_includes str, "ER  - \nTY  - JOUR\n"
        end
      end
    end
  end
end
