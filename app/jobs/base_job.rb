
# The exception raised when we kill a job externally
class JobKilledError < RuntimeError; end

# Base class for all jobs
#
# Analysis jobs have two special partials that can be implemented to
# engage novel behavior:
#
# - `_params.html.haml` (optional): If this view is present, then after the
#   task has collected the appropriate number of datasets, the user will be
#   presented with this form in order to set special parameters for the
#   task.  This partial should consist of a form that submits to
#   `dataset_tasks_path` with `:post` (`datasets/tasks#create`).
# - `results.html.haml` (optional): If this view is present, then after the
#   task is completed, the user will be offered a link to view this template
#   in addition to whatever downloadable file results the task produces.
class BaseJob < ActiveJob::Base
  queue_as :analysis

  # Try to rescue from everything, setting the failed bit
  rescue_from(Exception) do |e|
    task = arguments[0]
    if task.is_a?(Datasets::Task)
      task.mark_failed(e.backtrace[0] + ': ' + e.to_s)
    end

    # Try really very hard to prevent this job from sticking in the queue and
    # repeating until the end of time. The PostgreSQL JSON type is a thing of
    # pure beauty.
    active_job_id = @job_id
    query = <<-SQL
      DELETE FROM que_jobs
      WHERE args -> 0 ->> 'job_id' = '#{active_job_id}'
    SQL

    ActiveRecord::Base.connection.execute(query)
  end

  # Returns true if this job can be run right now
  #
  # In general, this checks if all required external tools are available.
  # It defaults to true in the base class, and can be overridden by jobs
  # which are sometimes not available.
  #
  # @return [Boolean] true if this job can be run now
  def self.available?
    true
  end

  # Return how many datasets this job requires
  #
  # This method defaults to 1 in the base class, and can be overridden by
  # jobs which require more than one dataset to operate.
  #
  # @return [Integer] number of datasets needed to perform this job
  def self.num_datasets
    1
  end

  # Returns a translated string for this job
  #
  # This handles the i18n scoping for analysis job classes.  It will
  # pass fully scoped translation keys along unaltered.
  #
  # @param [String] key the translation to look up (e.g., '.short_desc')
  # @param [Hash] opts the options for the translation
  # @return [String] the translated message
  def self.t(key, opts = {})
    return I18n.t(key, opts) unless key[0] == '.'

    I18n.t("#{name.underscore.tr('/', '.')}#{key}", opts)
  end

  # Returns a translated string for this job
  #
  # We alias the class method as an instance method, to save keystrokes
  # when programming job classes.
  #
  # @param [String] key the translation to look up (e.g., '.short_desc')
  # @return [String] the translated message
  def t(key, opts = {})
    self.class.t(key, opts)
  end

  # Get a list of all classes that are analysis jobs
  #
  # This method looks up all the defined job classes in `app/jobs` and returns
  # them in a list so that we may loop over them (e.g., when including all
  # job-start markup).
  #
  # @return [Array<Class>] array of class objects
  def self.job_list
    # Get all the job files
    analysis_files = Dir[Rails.root.join('app', 'jobs', '*.rb')]
    classes = analysis_files.map do |f|
      next if %w(base_job.rb
                 expire_tasks_job.rb).include?(File.basename(f))

      # This will raise a NameError if the class doesn't exist, but we want
      # that, because that means there's a file in app/jobs that doesn't
      # respect Rails' naming conventions.
      File.basename(f, '.rb').camelize.constantize
    end
    classes.compact!

    # Make sure that worked
    classes.each do |c|
      return [] unless c.is_a?(Class)
    end

    classes
  end

  # Get all of the available benchmarks for this job
  #
  # @return [Array<Admin::Benchmark>] all benchmarks for this class
  def self.benchmarks
    Admin::Benchmark.where(job: name).where.not(time: nil)
  end

  # Access the task, but only if it hasn't been deleted
  #
  # @return [Datasets::Task] the task we're working on
  def task
    check_task
    @task
  end

  # Access the dataset, but only if the job hasn't been deleted
  #
  # @return [Dataset] the dataset we are working on
  def dataset
    if @datasets
      fail ArgumentError, 'task was created with more than one dataset'
    end

    task.dataset
  end

  # Access the datasets (if created with more than one), but only if the job
  # hasn't been deleted
  #
  # @return [Array<Dataset>] the array of datasets we are working on
  def datasets
    unless @datasets
      fail ArgumentError, 'task was only created with one dataset'
    end

    check_task
    @datasets
  end

  # Access the user, but only if the job hasn't been deleted
  #
  # @return [User] the user whose dataset we are working on
  def user
    dataset.user
  end

  protected

  # Sets a variety of standard option variables
  #
  # This function checks to make sure that we have been sent a working task
  # handle by ActiveJob, and then sets and saves the name of the task to the
  # content of the `.short_desc` translation key. Finally, it starts the
  # progress measurement.
  #
  # This also enables support for the passing of options['other_datasets'] by
  # the job constructors. If multiple datasets are passed, they will be
  # accessible via the datasets function.
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options the other options sent to this job
  # @return [void]
  def standard_options(task, options = {})
    # This might be a HashWithIndifferentAccess, which doesn't have the
    # symbolize_keys! method. Either way, we'll have symbolic key access.
    options.symbolize_keys! if options.respond_to?(:symbolize_keys!)

    @task_id = task.id
    @task = task

    @task.name = t('.short_desc')
    @task.save

    @task.at(0, 100, t('common.progress_initializing'))

    # Set the @datasets variable if the :other_datasets option was passed
    return unless options.present?
    other_datasets = options[:other_datasets]

    return unless other_datasets
    other_datasets = [other_datasets] unless other_datasets.is_a?(Array)
    other_datasets.map! { |id| user.datasets.find(id) }

    @datasets = [dataset] + other_datasets
  end

  private

  # Checks to see if the task has been deleted
  #
  # @raise [JobKilledError] if the task has been deleted
  # @return [void]
  def check_task
    fail JobKilledError unless Datasets::Task.exists?(@task_id)
  end
end
