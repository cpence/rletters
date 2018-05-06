# frozen_string_literal: true

module Datasets
  # Work with a dataset's tasks
  #
  # @see Datasets::Task
  class TasksController < ApplicationController
    before_action :authenticate_user!
    before_action :set_task
    before_action :set_current_params, only: %i[new create]

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

      raise ArgumentError, "not enough datasets specified for #{params[:class]}"
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
      job = if @current_params.empty?
              @klass.perform_later(task)
            else
              @klass.perform_later(task, @current_params)
            end

      # Save the ActiveJob ID into the task for later
      task.job_id = job.job_id
      task.save

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

    # Delete a task
    #
    # This action deletes a given task and its associated files.
    #
    # @return [void]
    def destroy
      @task.destroy

      # We want to send the user back where they came from, which could either
      # be dataset_path(some_dataset) or workflow_fetch_path.
      redirect_back(fallback_location: workflow_fetch_path)
    end

    private

    # Get the task, dataset, and class objects from the params
    #
    # @return [void]
    def set_task
      @dataset = current_user.datasets.find(params[:dataset_id])
      @task = @dataset.tasks.find(params[:id]) if params[:id]
      @task_presenter = RLetters::Presenters::TaskPresenter.new(task: @task)
      @klass = Datasets::Task.job_class(params[:class]) if params[:class]
    end

    # Get the current parameters hash from the params
    #
    # @return [void]
    def set_current_params
      @current_params = params[:job_params]&.to_unsafe_h || {}
      @current_params = @current_params.with_indifferent_access
    end
  end
end
