# -*- encoding : utf-8 -*-

if Rails.env.test?
  require 'coveralls/rake/task'

  Coveralls::RakeTask.new
end
