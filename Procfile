release: bundle exec rails db:migrate db:seed
web: bundle exec puma -C config/puma.rb
worker: bundle exec rails rletters:jobs:analysis
