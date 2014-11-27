# -*- encoding : utf-8 -*-
require 'cucumber/rails'

ActionController::Base.allow_rescue = false
Cucumber::Rails::Database.javascript_strategy = :truncation
