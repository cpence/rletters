
module Datasets
  # Work with a dataset's tasks
  #
  # @see Datasets::Task
  class TasksController < ApplicationController
    before_action :authenticate_user!
    before_action :set_task
    before_action :set_current_params, only: [:new, :create]

    decorates_assigned :dataset, with: DatasetDecorator
    decorates_assigned :task, with: Datasets::TaskDecorator

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
      return if @current_params[:other_datasets]&.size ==
                (@klass.num_datasets - 1)

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

    # Show a view from a task
    #
    # This action will render a view that comes packaged with a background job.
    #
    # @return [void]
    def view
      render(@task.template_path(params[:template]),
             formats: [(params[:format] || :html).to_sym],
             locals: { klass: @task.job_class })
    end

    # Download a file from a task
    #
    # If the file is not available or downloadable, this action will raise
    # `ActiveRecord::RecordNotFound`.
    #
    # @return [void]
    def download
      # This cast will throw if the conversion cannot be performed
      file_number = Integer(params[:file])
      fail ActiveRecord::RecordNotFound if @task.files.count <= file_number

      @file = @task.files[file_number]
      fail ActiveRecord::RecordNotFound unless @file.downloadable

      send_data(@file.result.file_contents(:original),
                filename: @file.result_file_name,
                type: @file.result_content_type)
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
      @dataset = current_user.datasets.find(params[:dataset_id])
      @task = @dataset.tasks.find(params[:id]) if params[:id]
      @klass = Datasets::Task.job_class(params[:class]) if params[:class]
    end

    # Get the current parameters hash from the params
    #
    # @return [void]
    def set_current_params
      @current_params = params[:job_params] || {}
      @current_params = @current_params.with_indifferent_access
    end
  end
end
