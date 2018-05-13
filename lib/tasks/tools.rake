# frozen_string_literal: true

unless Rails.env.production?
  namespace :rletters do
    namespace :tools do
      desc 'Run security audits against the codebase'
      task :audit do
        system('bundle exec bundle-audit update')
        system('bundle exec bundle-audit')
        system('bundle exec brakeman -q')
      end

      desc 'Check code style with linters'
      task :lint do
        system('bundle exec rubocop')
        system('bundle exec haml-lint')
      end
    end
  end
end
