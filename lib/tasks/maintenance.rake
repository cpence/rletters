# frozen_string_literal: true

namespace :rletters do
  namespace :maintenance do
    desc 'Remove old finished tasks from the database'
    task expire_tasks: :environment do
      Datasets::Task.where('created_at < ?', 2.weeks.ago).destroy_all
    end
  end
end
