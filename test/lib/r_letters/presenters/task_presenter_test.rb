# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Presenters
    class TaskPresenterTest < ActiveSupport::TestCase
      test 'status_message works with both percent and message' do
        task = stub(progress: 0.3, progress_message: 'Going')
        pres = RLetters::Presenters::TaskPresenter.new(task: task)

        assert_equal '30%: Going', pres.status_message
      end

      test 'status_message works with only percent' do
        task = stub(progress: 0.3, progress_message: nil)
        pres = RLetters::Presenters::TaskPresenter.new(task: task)

        assert_equal '30%', pres.status_message
      end

      test 'status_message works with only message' do
        task = stub(progress: nil, progress_message: 'Going')
        pres = RLetters::Presenters::TaskPresenter.new(task: task)

        assert_equal 'Going', pres.status_message
      end
    end
  end
end
