
# Decorate analysis task objects
#
# This class adds methods to display the results from analysis tasks.
class TaskDecorator < Draper::Decorator
  decorates Datasets::Task
  delegate_all

  # A user-friendly status/percentage message
  #
  # @return [String] percentage message
  def status_message
    ret = ''

    hash = status
    if hash
      if hash.pct_complete
        ret += "#{hash.pct_complete}%"
        ret += ': ' if hash.message
      end
      ret += hash.message if hash.message
    end

    ret
  end
end
