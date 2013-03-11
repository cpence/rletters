# -*- encoding : utf-8 -*-
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'deploy')

# Utility for several recipes below
def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

# Gem recipes (Bundler, whenever, delayed_job)
require 'capistrano/maintenance'
require 'bundler/capistrano'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

# Local recipes
require 'capistrano_database'
require 'downloads_dir'
require 'god_restart'
require 'passenger'
require 'secret_token_replacer'
require 'seed'
require 'unicorn_config'
require 'unicorn_restart'

# Standard configuration options for fetching RLetters from GitHub
set :scm, :git
set :repository, "git@github.com:cpence/rletters.git"
set :branch, "master"
set :deploy_via, :remote_cache

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Your local application configuration
require 'deploy_config'
