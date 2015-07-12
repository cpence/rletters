
# Decorate task objects
#
# This class adds methods to display the results from tasks.
class TaskDecorator < Draper::Decorator
  decorates Datasets::Task
  delegate_all

  # A user-friendly status/percentage message
  #
  # @return [String] percentage message
  def status_message
    ret = ''

    if progress
      ret += "#{(progress * 100).to_i}%"
      ret += ': ' if progress_message.present?
    end
    ret += progress_message if progress_message.present?

    ret
  end
end
