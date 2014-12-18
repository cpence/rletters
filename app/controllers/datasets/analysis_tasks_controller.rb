# -*- encoding : utf-8 -*-

# Work with a dataset's analysis tasks
#
# @see Datasets::AnalysisTask
class Datasets::AnalysisTasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :set_current_params, only: [:new, :create]

  # Show the list of analysis tasks for this dataset
  #
  # This list needs to be updated live, as the tasks are running in the
  # background, so this is rendered without a layout for AJAX purposes.
  #
  # @api public
  # @return [void]
  def index
    render layout: false
  end

  # Collect parameters and data for a dataset
  #
  # This action collects parameters and data for starting a new dataset.
  #
  # @api public
  # @return [void]
  def new
    # Make sure we have enough other datasets, if those are required
    if @klass.num_datasets > 1
      other_datasets = @current_params[:other_datasets]

      if other_datasets.nil? ||
         other_datasets.size < (@klass.num_datasets - 1)
        fail ArgumentError, "not enough datasets specified for #{params[:class]}"
      end
    end
  end

  # Start an analysis task for this dataset
  #
  # This method dynamically determines the appropriate background job to start
  # and starts it.
  #
  # @api public
  # @return [void]
  def create
    # Create an analysis task
    task = @dataset.analysis_tasks.create(name: params[:class],
                                          job_type: params[:class])

    # Force these three parameters that we always need
    @current_params[:user_id] = current_user.to_param
    @current_params[:dataset_id] = @dataset.to_param
    @current_params[:task_id] = task.to_param

    # Save the Resque parameters into the task, as well
    task.params = @current_params
    task.save

    # Enqueue the job, saving the UUID for it
    task.resque_key = @klass.create(@current_params)
    task.save

    if current_user.workflow_active
      # If the user was in the workflow, they're done now
      current_user.workflow_active = false
      current_user.workflow_class = nil
      current_user.workflow_datasets = nil
      current_user.save

      redirect_to root_path,
                  flash: { success: I18n.t('datasets.analysis_tasks.create.workflow') }
    else
      # Advanced mode
      redirect_to dataset_path(@dataset),
                  flash: { success: I18n.t('datasets.create.building') }
    end
  end

  # Show a view from an analysis task, or download its results
  #
  # If this action is called with `params[:view]` set, then it will render
  # a view that comes packaged with a background job.  Without that parameter,
  # if this job has a result file saved, the file will be sent as a download.
  # If neither `params[:view]` nor a download is available, it will raise
  # `ActiveRecord::RecordNotFound`.
  #
  # @api public
  # @return [void]
  def show
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
  # @api private
  # @return [void]
  def set_task
    @dataset = current_user.datasets.active.find(params[:dataset_id])
    @task = @dataset.analysis_tasks.find(params[:id]) if params[:id].present?
    @klass = Datasets::AnalysisTask.job_class(params[:class]) if params[:class].present?
  end

  # Get the current parameters hash from the params
  #
  # @api private
  # @return [void]
  def set_current_params
    @current_params = params[:job_params].to_hash if params[:job_params]
    @current_params ||= {}
    @current_params.symbolize_keys!
  end

  # Render a job view, given the class name and view name
  #
  # @api private
  # @param [Class] klass the job class
  # @param [String] view the view to render
  # @param [String] format the file format for the view (e.g., `csv` or `html`)
  # @return [void]
  def render_job_view(klass, view, format = 'html')
    path = klass.view_path(template: view, format: format)
    fail ActiveRecord::RecordNotFound unless path

    if @task.result_file_size
      @json = @task.result.file_contents(:original).force_encoding('utf-8')
      @json_escaped = @json.gsub('\\', '\\\\').gsub("'", "\\\\'").gsub('\n', '\\\\\\\\n').gsub('"', '\\\\"').html_safe
    end

    render file: path, locals: { klass: klass }
  end
end
