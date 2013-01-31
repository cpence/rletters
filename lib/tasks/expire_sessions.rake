# -*- encoding : utf-8 -*-

namespace :db do
  
  namespace :sessions do
    
    desc "Clean up expired Active Record sessions (created before ENV['CREATED_AT'])."
    task :expire => :environment do
      created_time = Time.parse( ENV['CREATED_AT'] || 2.days.ago.to_s(:db) )
      
      puts "cleaning up expired sessions (created before #{created_time}) ..."
      session = ActiveRecord::SessionStore::Session
      rows = session.delete_all ["created_at < ?", created_time]
      puts "deleted #{rows} session row(s) - there are #{session.count} session row(s) left"
    end
    
  end
end
