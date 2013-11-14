# -*- encoding : utf-8 -*-

# Work with a dataset's analysis tasks
#
# @see Datasets::AnalysisTask
class Datasets::AnalysisTasksController < ApplicationController
  before_filter :authenticate_user!

  # Show the list of analysis tasks for this dataset
  #
  # This list needs to be updated live, as the tasks are running in the
  # background.
  #
  # @api public
  # @return [undefined]
  def index
    @dataset = current_user.datasets.active.find(params[:dataset_id])
    render layout: false
  end

  # Collect parameters and data for a dataset
  #
  # This action collects parameters and data for starting a new dataset.
  #
  # @api public
  # @return [undefined]
  def new
    # Get the dataset and the class
    @dataset = current_user.datasets.active.find(params[:dataset_id])
    @klass = Datasets::AnalysisTask.job_class(params[:class])

    # Get the parameters we've specified so far
    job_params = params[:job_params].to_hash if params[:job_params]
    job_params ||= {}
    job_params.symbolize_keys!

    # Make sure we have enough other datasets, if those are required
    if @klass.num_datasets > 1
      other_datasets = job_params[:other_datasets]

      if other_datasets.nil? ||
         other_datasets.count < (@klass.num_datasets - 1)
        # Still need more other datasets, render the data collection view
        # and bail
        if @klass.has_view? '_params'
          # We still need parameters, so post right back to this page
          @form_url = new_dataset_analysis_task_path(@dataset, class: params[:class])
          @form_method = :get
        else
          # No parameters, just create it
          @form_url = dataset_analysis_tasks_path(@dataset, class: params[:class])
          @form_method = :post
        end

        render 'new_datasets'
        return
      end
    end

    # Gather the parameters for the task.  If there aren't any, then this
    # action shouldn't have been called, just let it fail.
    render 'new_params'
  end

  # Start an analysis task for this dataset
  #
  # This method dynamically determines the appropriate background job to start
  # and starts it.
  #
  # @api public
  # @return [undefined]
  def create
    # Get the dataset and the class
    @dataset = current_user.datasets.active.find(params[:dataset_id])
    @klass = Datasets::AnalysisTask.job_class(params[:class])

    # Get the parameters we've specified so far
    job_params = params[:job_params].to_hash if params[:job_params]
    job_params ||= {}
    job_params.symbolize_keys!

    # Create an analysis task
    task = @dataset.analysis_tasks.create(name: params[:class],
                                          job_type: params[:class])

    # Force these three parameters that we always need
    job_params[:user_id] = current_user.to_param
    job_params[:dataset_id] = @dataset.to_param
    job_params[:task_id] = task.to_param

    # Save the Resque parameters into the task, as well
    task.params = job_params
    task.save

    # Enqueue the job
    Resque.enqueue(@klass, job_params)

    if current_user.workflow_active
      # If the user was in the workflow, they're done now
      current_user.workflow_active = false
      current_user.workflow_class = nil
      current_user.workflow_datasets = nil
      current_user.save

      redirect_to root_path,
                  flash: { success: I18n.t('datasets.create.workflow') }
    else
      # Advanced mode
      redirect_to dataset_path(@dataset),
                  flash: { success: I18n.t('datasets.create.success') }
    end
  end

  # Show a view from an analysis task, or download its results
  #
  # If this action is called with +params[:view]+ set, then it will render
  # a view that comes packaged with a background job.  Without that parameter,
  # if this job has a result file saved, the file will be sent as a download.
  # If neither +params[:view]+ nor a download is available, it will raise
  # +ActiveRecord::RecordNotFound+.
  #
  # @api public
  # @return [undefined]
  def show
    @dataset = current_user.datasets.active.find(params[:dataset_id])
    @task = @dataset.analysis_tasks.find(params[:id])

    if params[:view]
      render_job_view(@task.job_class, params[:view], params[:format] || 'html')
      return
    end

    if @task.result_file_size
      send_data(@task.result.file_contents(:original),
                filename: @task.result_file_name,
                type: @task.result_content_type)
      return
    end

    fail ActiveRecord::RecordNotFound
  end

  # Delete an analysis task
  #
  # This action deletes a given analysis task and its associated files.
  #
  # @api public
  # @return [undefined]
  def destroy
    dataset = current_user.datasets.active.find(params[:dataset_id])
    task = dataset.analysis_tasks.find(params[:id])

    task.destroy

    # We want to send the user back where they came from, which could either
    # be dataset_path(some_dataset) or workflow_fetch_path.
    redirect_to :back
  end

  private

  # Render a job view, given the class name and view name
  #
  # @param [Class] klass the job class
  # @param [String] view the view to render
  # @return [undefined]
  def render_job_view(klass, view, format = 'html')
    path = klass.view_path(template: view, format: format)
    fail ActiveRecord::RecordNotFound unless path

    render file: path, locals: { klass: klass }
  end
end
