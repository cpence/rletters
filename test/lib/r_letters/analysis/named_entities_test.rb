# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Analysis
    class NamedEntitiesTest < ActiveSupport::TestCase
      test 'works' do
        old_path = ENV['NLP_TOOL_PATH']
        ENV['NLP_TOOL_PATH'] = 'stubbed'

        entities = build(:named_entities)
        RLetters::Analysis::NLP.expects(:named_entities).returns(entities)

        called_sub_100 = false
        called_100 = false

        refs = RLetters::Analysis::NamedEntities.call(
          dataset: create(:full_dataset),
          progress: lambda do |p|
            if p < 100
              called_sub_100 = true
            else
              called_100 = true
            end
          end)

        assert_includes refs['PERSON'], 'Harry'

        assert called_sub_100
        assert called_100

        ENV['NLP_TOOL_PATH'] = old_path
      end
    end
  end
end
