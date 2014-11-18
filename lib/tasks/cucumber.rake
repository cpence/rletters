# -*- encoding : utf-8 -*-
unless Rails.env.production?
  vendored_cucumber_bin = Dir["#{Rails.root}/vendor/{gems,plugins}/cucumber*/bin/cucumber"].first
  $LOAD_PATH.unshift(File.dirname(vendored_cucumber_bin) + '/../lib') unless vendored_cucumber_bin.nil?

  require 'cucumber/rake/task'

  namespace :cucumber do
    Cucumber::Rake::Task.new({ ok: 'test:prepare' }, 'Run features that should pass') do |t|
      t.binary = vendored_cucumber_bin # If nil, the gem's binary is used.
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'default'
    end

    Cucumber::Rake::Task.new({ wip: 'test:prepare' }, 'Run features that are being worked on') do |t|
      t.binary = vendored_cucumber_bin
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'wip'
    end

    Cucumber::Rake::Task.new({ rerun: 'test:prepare' }, 'Record failing features and run only them if any exist') do |t|
      t.binary = vendored_cucumber_bin
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'rerun'
    end

    Cucumber::Rake::Task.new({ first: 'test:prepare' }, 'Run a first features pass') do |t|
      t.binary = vendored_cucumber_bin # If nil, the gem's binary is used.
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'first_try'
    end

    Cucumber::Rake::Task.new({ second: 'test:prepare' }, 'Run a second features pass') do |t|
      t.binary = vendored_cucumber_bin # If nil, the gem's binary is used.
      t.fork = true # You may get faster startup if you set this to false
      t.profile = 'second_try'
    end

    desc 'Run all features, retrying failures once'
    task all: [:first, :second]

    task :statsetup do
      require 'rails/code_statistics'
      ::STATS_DIRECTORIES << %w(Cucumber\ features features) if File.exist?('features')
      ::CodeStatistics::TEST_TYPES << 'Cucumber features' if File.exist?('features')
    end
  end

  desc 'Alias for cucumber:all'
  task cucumber: 'cucumber:all'

  task stats: 'cucumber:statsetup'
end
