# -*- encoding : utf-8 -*-

module Jobs

  # Expire any sessions older than two days.
  class ExpireDownloads < Jobs::Base
    
    # Expire old sessions
    #
    # @api public
    # @return [undefined]
    # @example Start a job for expiring all old sessions
    #   Delayed::Job.enqueue Jobs::ExpireSessions.new
    def perform
      session = ActiveRecord::SessionStore::Session
      session.delete_all ["created_at < ?", 2.days.ago]
    end
  end
end
