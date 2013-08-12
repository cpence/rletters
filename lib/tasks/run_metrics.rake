# -*- encoding : utf-8 -*-
require 'fileutils'

namespace :metrics do
  require 'rubocop/rake_task'
  Rubocop::RakeTask.new do |t|
    t.patterns = ['--format', 'emacs',
                  '--out', 'doc/metrics/rubocop.txt',
                  '--rails']
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

  require 'rails_best_practices'
  desc 'Run rails_best_practices'
  task :rails_best_practices do
    analyzer = RailsBestPractices::Analyzer.new(
      '.',
      { 'format' => 'html',
        'output-file' => 'doc/metrics/railsbp.html' })
    analyzer.analyze
    analyzer.output
  end

  desc 'Clean up metric products'
  task :clean do
    FileUtils.rm_f File.join('doc', 'metrics', 'rubocop.txt')
    FileUtils.rm_f File.join('doc', 'metrics', 'yardstick.txt')
    FileUtils.rm_f File.join('doc', 'metrics', 'brakeman.html')
    FileUtils.rm_f File.join('doc', 'metrics', 'excellent.html')
    FileUtils.rm_f File.join('doc', 'metrics', 'railsbp.html')
  end

  desc 'Run all available code metrics'
  task all: ['metrics:rubocop', 'metrics:yardstick', 'metrics:excellent',
             'metrics:rails_best_practices']
end
