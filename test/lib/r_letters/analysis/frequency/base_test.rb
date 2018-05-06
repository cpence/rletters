# frozen_string_literal: true
require 'test_helper'

class RLetters::Analysis::Frequency::BaseTest < ActiveSupport::TestCase
  test 'creates FromTF when available' do
    analyzer = RLetters::Analysis::Frequency::Base.call(dataset: create(:full_dataset))

    assert_kind_of RLetters::Analysis::Frequency::FromTF, analyzer
  end

  test 'creates FromPosition otherwise' do
    analyzer = RLetters::Analysis::Frequency::Base.call(dataset: create(:full_dataset),
                                                        'num_blocks' => 3,
                                                        'ngrams' => 2)

    assert_kind_of RLetters::Analysis::Frequency::FromPosition, analyzer
  end
end
