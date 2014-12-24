unless Rails.env.production?
  namespace :security do
    desc 'Run security audits against the codebase'
    task :audit do
      Bundler.with_clean_env do
        system('bundle-audit update')
        system('bundle-audit')
        system('brakeman -q')
      end
    end
  end
end
