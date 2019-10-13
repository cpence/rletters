require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/bundler'
require 'capistrano/yarn'
require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'
require 'capistrano/maintenance'
require 'capistrano/sentry'

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
