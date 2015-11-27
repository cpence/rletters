
def benchmark_job(dataset, klass, size, params = nil)
  unless klass.available?
    puts "...cannot benchmark #{klass.name}, not available"
    return
  end

  puts "...benchmarking the #{klass.name} at size #{size}"

  task = dataset.tasks.create!(name: 'Benchmark Task', job_type: klass.name)

  time = Benchmark.realtime do
    if params
      klass.new.perform(task, params)
    else
      klass.new.perform(task)
    end
  end

  bench = Admin::Benchmark.find_by!(job: klass.name, size: size)
  bench.time = time
  bench.save
end

namespace :benchmarks do
  desc 'Update benchmarks for all available jobs (warning: slow!)'
  task update: :environment do
    # Pipe down, logs
    Rails.application.config.log_level = 'WARN'
    Rails.logger.level = Logger::WARN

    job_classes = BaseJob.job_list
    set_sizes = [10, 100, 1000]

    # Start by making each of the benchmark objects and nil-ing it out
    job_classes.each do |klass|
      set_sizes.each do |size|
        bench = Admin::Benchmark.where(job: klass.name, size: size).first_or_create
        bench.time = nil
        bench.save!
      end
    end

    # Get a search result containing some UIDs for our use later
    result = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene',
                                               fl: 'uid', rows: 1000)

    # Build us a temporary user
    user = User.create!(name: 'Maintenance User',
                        email: 'rletters@rletters.net',
                        language: 'en',
                        timezone: 'Eastern Time (US & Canada)',
                        password: 'password',
                        password_confirmation: 'password')

    begin
      set_sizes.each do |size|
        # Generate the query
        docs = result.documents.take(size)
        query = "uid:(#{docs.map { |d| "\"#{d.uid}\"" }.join(' OR ')})"

        # Build a couple datasets and some queries to fill them
        dataset = user.datasets.create!(name: 'Maintenance Dataset')
        dataset.queries.create!(q: query, def_type: 'lucene')
        second_dataset = user.datasets.create!(name: 'Second Maint Dataset')
        second_dataset.queries.create!(q: query, def_type: 'lucene')

        begin
          benchmark_job(dataset, ArticleDatesJob, size)
          benchmark_job(dataset, CollocationJob, size, scoring: 'mutual_information')
          benchmark_job(dataset, CooccurrenceJob, size, scoring: 'mutual_information', words: 'though')
          benchmark_job(dataset, CraigZetaJob, size, other_datasets: [second_dataset.id])
          benchmark_job(dataset, ExportCitationsJob, size, format: 'bibtex')
          benchmark_job(dataset, NamedEntitiesJob, size)
          benchmark_job(dataset, NetworkJob, size, word: 'though')
          benchmark_job(dataset, TermDatesJob, size, term: 'though')
          benchmark_job(dataset, WordFrequencyJob, size)
        ensure
          # Do not leave our temporary dataset in the database
          dataset.destroy
        end
      end
    ensure
      # Do not leave our temporary user in the database
      user.destroy
    end
  end
end
