# -*- encoding : utf-8 -*-

# Display, modify, delete, and analyze datasets belonging to a given user
#
# This controller is responsible for the handling of the datasets which
# belong to a given user.  It displays the user's list of datasets, and
# handles the starting and management of the user's background analysis
# tasks.
#
# @see Dataset
class DatasetsController < ApplicationController
  before_filter :authenticate_user!

  # Show all of the current user's datasets
  # @api public
  # @return [undefined]
  def index; end

  # Show the list of datasets for this user
  #
  # This list needs to be updated live, as the datasets are being created
  # in the background.  This action is to be called via AJAX.
  #
  # @api public
  # @return [undefined]
  def dataset_list
    @datasets = current_user.datasets
    render layout: false
  end

  # Show information about the requested dataset
  #
  # This action also includes links for users to perform various analysis
  # tasks on the dataset.
  #
  # @api public
  # @return [undefined]
  def show
    @dataset = current_user.datasets.find(params[:id])
    fail ActiveRecord::RecordNotFound unless @dataset

    if params[:clear_failed] && @dataset.analysis_tasks.failed.count > 0
      @dataset.analysis_tasks.failed.destroy_all
      flash[:notice] = t('datasets.show.deleted')
    end
  end

  # Show the form for creating a new dataset
  # @api public
  # @return [undefined]
  def new
    @dataset = current_user.datasets.build
    render layout: false
  end

  # Create a new dataset in the database
  # @api public
  # @return [undefined]
  def create
    Resque.enqueue(Jobs::CreateDataset,
                   user_id: current_user.to_param,
                   name: dataset_params[:name],
                   q: params[:q],
                   fq: params[:fq],
                   defType: params[:defType])

    if current_user.workflow_active
      redirect_to workflow_activate_path(current_user.workflow_class),
                  flash: { success: I18n.t('datasets.create.building_workflow') }
    else
      redirect_to datasets_path,
                  flash: { success: I18n.t('datasets.create.building') }
    end
  end

  # Delete a dataset from the database
  # @api public
  # @return [undefined]
  def destroy
    @dataset = current_user.datasets.find(params[:id])
    fail ActiveRecord::RecordNotFound unless @dataset

    Resque.enqueue(Jobs::DestroyDataset,
                   user_id: current_user.to_param,
                   dataset_id: params[:id])

    redirect_to datasets_path
  end

  # Add a single document to a dataset
  # @api public
  # @return [undefined]
  def add
    # This isn't a member action, so that it can be called easily from
    # a form.  Get the id from :dataset_id, not :id.
    @dataset = current_user.datasets.find(params[:dataset_id])
    @document = Document.find(params[:shasum])

    # No reason for this to be a delayed job, just do the create
    @dataset.entries.create({ shasum: params[:shasum] })
    redirect_to dataset_path(@dataset)
  end

  # Show the list of analysis tasks for this dataset
  #
  # This list needs to be updated live, as the tasks are running in the
  # background, so we split this off to a small AJAX action.
  #
  # @api public
  # @return [undefined]
  def task_list
    @dataset = current_user.datasets.find(params[:id])
    fail ActiveRecord::RecordNotFound unless @dataset

    render layout: false
  end

  # Start an analysis task for this dataset
  #
  # This method dynamically determines the appropriate background job to start
  # and starts it.  It requires a dataset ID.
  #
  # @api public
  # @return [undefined]
  def task_start
    # Get the dataset and the class
    @dataset = current_user.datasets.find(params[:id])
    fail ActiveRecord::RecordNotFound unless @dataset
    @klass = AnalysisTask.job_class(params[:class])

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
        render 'task_datasets'
        return
      end
    end

    # Make sure we've gathered the parameters, if those are required
    if @klass.has_view?('_params')
      unless job_params[:start]
        render 'task_params'
        return
      end
    end

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
                  flash: { success: I18n.t('datasets.task_start.workflow') }
    else
      # Advanced mode
      redirect_to dataset_path(@dataset),
                  flash: { success: I18n.t('datasets.task_start.success') }
    end
  end

  # Show a view from an analysis task
  #
  # Background jobs are packaged with some of their own views.  This controller
  # action renders one of those views directly.
  #
  # @api public
  # @return [undefined]
  def task_view
    @dataset = current_user.datasets.find(params[:id])
    fail ActiveRecord::RecordNotFound unless @dataset
    fail ActiveRecord::RecordNotFound unless params[:view]

    if params[:class]
      klass = AnalysisTask.job_class(params[:class])
    else
      @task = @dataset.analysis_tasks.find(params[:task_id])
      fail ActiveRecord::RecordNotFound unless @task

      klass = @task.job_class
    end

    render_job_view(klass, params[:view], params[:format] || 'html')
  end

  # Delete an analysis task
  #
  # This action deletes a given analysis task and its associated files.
  #
  # @api public
  # @return [undefined]
  def task_destroy
    dataset = current_user.datasets.find(params[:id])
    fail ActiveRecord::RecordNotFound unless dataset

    task = dataset.analysis_tasks.find(params[:task_id])
    fail ActiveRecord::RecordNotFound unless task

    task.destroy

    # We want to send the user back where they came from, which could either
    # be dataset_path(some_dataset) or workflow_fetch_path.
    redirect_to :back
  end

  # Download a file from an analysis task
  #
  # This method sends a user a result file from an analysis task.  It requires
  # a dataset ID and a task ID.
  #
  # @api public
  # @return [undefined]
  def task_download
    dataset = current_user.datasets.find(params[:id])
    fail ActiveRecord::RecordNotFound unless dataset
    task = dataset.analysis_tasks.find(params[:task_id])
    fail ActiveRecord::RecordNotFound unless task
    fail ActiveRecord::RecordNotFound unless task.result_file_size

    send_data(task.result.file_contents(:original),
              filename: task.result_file_name,
              type: task.result_content_type)
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

  # Whitelist acceptable dataset parameters
  #
  # @return [ActionController::Parameters] acceptable parameters for
  #   mass-assignment
  def dataset_params
    params.require(:dataset).permit(:name)
  end
end
