
module RLetters
  module Presenters
    # Code for formatting attributes of a Task object
    class TaskPresenter
      include Virtus.model(strict: true, required: true)
      attribute :task, ::Datasets::Task

      # Get the JSON content from a file, escaped for JavaScript
      #
      # If there is no JSON file attached to this task, this method will return
      # `nil`.
      #
      # @return [String] JSON data, escaped, as string (or `nil`)
      def json_escaped
        ret = task.json
        return nil if ret.nil?

        ret.gsub('\\', '\\\\')
          .gsub("'", "\\\\'")
          .gsub('\n', '\\\\\\\\n')
          .gsub('"', '\\\\"')
          .html_safe
      end

      # A user-friendly status/percentage message
      #
      # @return [String] percentage message
      def status_message
        ret = ''

        if task.progress
          ret << "#{(task.progress * 100).to_i}%"
          ret << ': ' if task.progress_message.present?
        end
        ret << task.progress_message if task.progress_message.present?

        ret
      end
    end
  end
end
