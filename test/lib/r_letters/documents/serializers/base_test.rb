# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Documents
    module Serializers
      class BaseTest < ActiveSupport::TestCase
        test 'available works' do
          list = RLetters::Documents::Serializers::Base.available

          assert_kind_of Array, list
          assert_includes list, :bibtex
        end

        test 'for works' do
          RLetters::Documents::Serializers::Base.available.each do |ser|
            assert_kind_of Class,
                           RLetters::Documents::Serializers::Base.for(ser)
          end
        end
      end
    end
  end
end
