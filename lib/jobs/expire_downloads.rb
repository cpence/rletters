# -*- encoding : utf-8 -*-

module Jobs

  # Expire any downloads older than two weeks.
  class ExpireDownloads < Jobs::Base
    
    # Expire old downloads
    #
    # @api public
    # @return [undefined]
    # @example Start a job for expiring all old downloads
    #   Delayed::Job.enqueue Jobs::ExpireDownloads.new
    def perform
      # Note: This *must* be destroy_all, because we want to make sure to call
      # the +Download#delete_file+ callback in +before_destroy.+
      Download.destroy_all ["created_at < ?", 2.weeks.ago]
    end
  end
end
