# -*- encoding : utf-8 -*-

namespace :resque do
  task :setup => :environment do
    require 'resque'

    # FIXME: For external job workers, we'll have to fix this.  But not just
    # yet.
    Resque.redis = 'localhost:6379'
  end
end
