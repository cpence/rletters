# -*- encoding : utf-8 -*-
require File.expand_path('./boot',        __FILE__)
require File.expand_path('./environment', __FILE__)
require 'clockwork'

include Clockwork

every(1.hours, 'Queueing session expiration job') { Delayed::Job.enqueue Jobs::ExpireSessions.new }
every(1.hours, 'Queueing download expiration job') { Delayed::Job.enqueue Jobs::ExpireDownloads.new }
