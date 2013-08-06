#!/usr/bin/env rake

require File.expand_path('../config/application', __FILE__)
RLetters::Application.load_tasks

require 'rubocop/rake_task'
Rubocop::RakeTask.new do |t|
  t.patterns = ['--format', 'emacs', '--out', 'doc/metrics/rubocop.txt', '--rails']
  t.fail_on_error = false
end

require 'yardstick/rake/measurement'
Yardstick::Rake::Measurement.new(:yardstick) do |t|
  t.output = 'doc/metrics/yardstick.txt'
end

# This task is broken at the moment on Brakeman 2.1.0; pending
# https://github.com/presidentbeef/brakeman/issues/373
require 'brakeman'
desc 'Run Brakeman'
task :brakeman do |t|
  Brakeman.run(app_path: '.', output_file: 'doc/metrics/brakeman.html',
               print_report: true)
end

require 'simplabs/excellent/rake'
Simplabs::Excellent::Rake::ExcellentTask.new(:excellent) do |t|
  t.html = 'doc/metrics/excellent.html'
  t.paths = %w{app lib}
end


desc "Run all available code metrics"
task :metrics => [:rubocop, :yardstick, :excellent]
