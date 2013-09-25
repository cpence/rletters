# -*- encoding : utf-8 -*-

namespace :metrics do
  task :rubocop do
    outfile = Rails.root.join('doc', 'metrics', 'rubocop.txt')
    Bundler.with_clean_env { system("rubocop --format emacs --out #{outfile} --rails") }
  end

  task :yardstick do
    outfile = Rails.root.join('doc', 'metrics', 'yardstick.txt')
    Bundler.with_clean_env { system("yardstick #{Rails.root.join('app', '**', '*.rb')} #{Rails.root.join('app', '**', '*.rb')} > #{outfile}") }
  end

  task :brakeman do
    outfile = Rails.root.join('doc', 'metrics', 'brakeman.html')
    Bundler.with_clean_env { system("brakeman -p #{Rails.root} -f html -o #{outfile}") }
  end

  task :excellent do
    outfile = Rails.root.join('doc', 'metrics', 'excellent.html')
    Bundler.with_clean_env { system("excellent -o #{outfile} app lib") }
  end

  task :rails_best_practices do
    outfile = Rails.root.join('doc', 'metrics', 'railsbp.html')
    Bundler.with_clean_env { system("rails_best_practices -f html --output-file #{outfile} .") }
  end

  desc 'Clean up metric products'
  task :clean do
    require 'fileutils'

    FileUtils.rm_f File.join('doc', 'metrics', 'rubocop.txt')
    FileUtils.rm_f File.join('doc', 'metrics', 'yardstick.txt')
    FileUtils.rm_f File.join('doc', 'metrics', 'brakeman.html')
    FileUtils.rm_f File.join('doc', 'metrics', 'excellent.html')
    FileUtils.rm_f File.join('doc', 'metrics', 'railsbp.html')
  end

  desc 'Run all available code metrics'
  task all: ['metrics:rubocop', 'metrics:yardstick', 'metrics:excellent',
             'metrics:brakeman', 'metrics:rails_best_practices']
end
