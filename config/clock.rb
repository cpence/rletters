# -*- encoding : utf-8 -*-
require File.expand_path('../boot',        __FILE__)
require File.expand_path('../environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.hours, 'Queueing analysis task expiration job') do
  Resque.enqueue(Jobs::ExpireAnalysisTasks)
end
