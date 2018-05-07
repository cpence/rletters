# frozen_string_literal: true

require 'test_helper'

module Datasets
  class FileTest < ActiveSupport::TestCase
    test 'should be invalid without description' do
      file = build_stubbed(:file, description: nil)

      refute file.valid?
    end

    test 'should be valid with description' do
      file = create(:file)

      assert file.valid?
    end
  end
end
