# frozen_string_literal: true

module RLetters
  module Presenters
    # Code for formatting attributes of a Task object
    class TaskPresenter
      include Virtus.model(strict: true, required: true)
      attribute :task, ::Datasets::Task

      # A user-friendly status/percentage message
      #
      # @return [String] percentage message
      def status_message
        ''.dup.tap do |ret|
          if task.progress
            ret << "#{(task.progress * 100).to_i}%"
            ret << ': ' if task.progress_message.present?
          end
          ret << task.progress_message if task.progress_message.present?
        end
      end
    end
  end
end
