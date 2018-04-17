unless Rails.env.production?
  namespace :tools do
    desc 'Run security audits against the codebase'
    task :audit do
      system('bundle exec bundle-audit update')
      system('bundle exec bundle-audit')
      system('bundle exec brakeman -q')
    end

    desc 'Check code style with Rubocop'
    task :style do
      system('bundle exec rubocop')
    end
  end
end
