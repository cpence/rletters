
# Decorate analysis task objects
#
# This class adds methods to display the results from analysis tasks.
class AnalysisTaskDecorator < Draper::Decorator
  decorates Datasets::AnalysisTask
  delegate_all

  # A user-friendly status/percentage message
  #
  # @api public
  # @return [String] percentage message
  # @example Display the status of a task
  #   = @tasks[0].status_message
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
