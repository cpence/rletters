
module Datasets
  # Work with a dataset's tasks
  #
  # @see Datasets::Task
  class TasksController < ApplicationController
    before_action :authenticate_user!
    before_action :set_task
    before_action :set_current_params, only: [:new, :create]

    # Show the list of tasks for this dataset
    #
    # This list needs to be updated live, as the tasks are running in the
    # background, so this is rendered without a layout for AJAX purposes.
    #
    # @return [void]
    def index
      render layout: false
    end

    # Collect parameters and data for a dataset
    #
    # This action collects parameters and data for starting a new dataset.
    #
    # @return [void]
    def new
      # Make sure we have enough other datasets, if those are required
      return if @klass.num_datasets == 1
      return if @current_params[:other_datasets] &&
                (@current_params[:other_datasets].size ==
                 (@klass.num_datasets - 1))

      fail ArgumentError, "not enough datasets specified for #{params[:class]}"
    end

    # Start an task for this dataset
    #
    # This method dynamically determines the appropriate background job to start
    # and starts it.
    #
    # @return [void]
    def create
      # Create a task
      task = @dataset.tasks.create(name: params[:class],
                                   job_type: params[:class])

      # Enqueue the job
      if @current_params.empty?
        @klass.perform_later(task)
      else
        @klass.perform_later(task, @current_params)
      end

      if current_user.workflow_active
        # If the user was in the workflow, they're done now
        current_user.workflow_active = false
        current_user.workflow_class = nil
        current_user.workflow_datasets.clear
        current_user.save

        redirect_to root_path,
                    flash: { success: I18n.t('datasets.tasks.create.workflow') }
      else
        # Advanced mode
        redirect_to dataset_path(@dataset),
                    flash: { success: I18n.t('datasets.create.building') }
      end
    end

    # Show a view from a task, or download its results
    #
    # If this action is called with `params[:view]` set, then it will render
    # a view that comes packaged with a background job.  Without that parameter,
    # if this job has a result file saved, the file will be sent as a download.
    # If neither `params[:view]` nor a download is available, it will raise
    # `ActiveRecord::RecordNotFound`.
    #
    # @return [void]
    def show
      if params[:view]
        if @task.files.count > 0
          # FIXME: We will figure out a way to actually key off of the JSON
          # file type when you have multiple-file tasks
          @json = @task.files[0].result.file_contents(:original).force_encoding('utf-8')
          @json_escaped = @json.gsub('\\', '\\\\').gsub("'", "\\\\'").gsub('\n', '\\\\\\\\n').gsub('"', '\\\\"').html_safe
        end

        render("jobs/#{@task.job_class.name.underscore}/#{params[:view]}",
               formats: [(params[:format] || :html).to_sym],
               locals: { klass: @task.job_class })
        return
      end

      if @task.files.count > 0
        # FIXME: This action needs to take a parameter that tells you which
        # file you want to download, as well as whether or not that file is
        # allowed to be downloaded
        send_data(@task.files[0].result.file_contents(:original),
                  filename: @task.files[0].result_file_name,
                  type: @task.files[0].result_content_type)
        return
      end

      fail ActiveRecord::RecordNotFound
    end

    # Delete a task
    #
    # This action deletes a given task and its associated files.
    #
    # @return [void]
    def destroy
      @task.destroy

      # We want to send the user back where they came from, which could either
      # be dataset_path(some_dataset) or workflow_fetch_path.
      redirect_to :back
    end

    private

    # Get the task, dataset, and class objects from the params
    #
    # @return [void]
    def set_task
      @dataset = current_user.datasets.active.find(params[:dataset_id])
      @task = @dataset.tasks.find(params[:id]) if params[:id].present?
      @klass = Datasets::Task.job_class(params[:class]) if params[:class].present?
    end

    # Get the current parameters hash from the params
    #
    # @return [void]
    def set_current_params
      if params[:job_params]
        @current_params = params[:job_params].to_hash.with_indifferent_access
      end
      @current_params ||= {}.with_indifferent_access
    end
  end
end
