# -*- encoding : utf-8 -*-

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
        if hash.message
          ret += ": "
        end
      end
      if hash.message
        ret += hash.message
      end
    end

    ret
  end
end
