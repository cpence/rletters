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
  def index
  end

  # Show the list of datasets for this user
  #
  # This list needs to be updated live, as the datasets are being created
  # in the background.  This action is to be called via AJAX.
  #
  # @api public
  # @return [undefined]
  def dataset_list
    @datasets = current_user.datasets
    render :layout => false
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
    raise ActiveRecord::RecordNotFound unless @dataset

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
    render :layout => 'dialog'
  end

  # Show a confirmation box for deleting a dataset
  # @api public
  # @return [undefined]
  def delete
    @dataset = current_user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset
    render :layout => 'dialog'
  end

  # Create a new dataset in the database
  # @api public
  # @return [undefined]
  def create
    Delayed::Job.enqueue Jobs::CreateDataset.new(
      :user_id => current_user.to_param,
      :name => dataset_params[:name],
      :q => params[:q],
      :fq => params[:fq],
      :qt => params[:qt]), :queue => 'ui'

    redirect_to datasets_path, :notice => I18n.t('datasets.create.building')
  end

  # Delete a dataset from the database
  # @api public
  # @return [undefined]
  def destroy
    @dataset = current_user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @dataset
    redirect_to @dataset and return if params[:cancel]

    Delayed::Job.enqueue Jobs::DestroyDataset.new(
      :user_id => current_user.to_param,
      :dataset_id => params[:id]), :queue => 'ui'

    redirect_to datasets_path
  end

  # Add a single document to a dataset
  # @api public
  # @return [undefined]
  def add
    # This isn't a member action, so that it can be called easily from
    # a form.  Get the id from :dataset_id, not :id.
    @dataset = current_user.datasets.find(params[:dataset_id])
    raise ActiveRecord::RecordNotFound unless @dataset
    @document = Document.find(params[:shasum])
    raise ActiveRecord::RecordNotFound unless @document

    # No reason for this to be a delayed job, just do the create
    @dataset.entries.create({ :shasum => params[:shasum] })
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
    raise ActiveRecord::RecordNotFound unless @dataset

    render :layout => false
  end

  # Start an analysis task for this dataset
  #
  # This method dynamically determines the appropriate background job to start
  # and starts it.  It requires a dataset ID.
  #
  # @api public
  # @return [undefined]
  def task_start
    dataset = current_user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless dataset
    klass = AnalysisTask.job_class(params[:class])

    # Put the job parameters together out of the job hash
    job_params = {}
    if params[:job_params]
      job_params = params[:job_params].to_hash
      job_params.symbolize_keys!
    end
    job_params[:user_id] = current_user.to_param
    job_params[:dataset_id] = dataset.to_param

    # Enqueue the job
    Delayed::Job.enqueue klass.new(job_params), :queue => 'analysis'
    redirect_to dataset_path(dataset)
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
    raise ActiveRecord::RecordNotFound unless @dataset

    @task = @dataset.analysis_tasks.find(params[:task_id])
    raise ActiveRecord::RecordNotFound unless @task

    raise ActiveRecord::RecordNotFound unless params[:view]

    klass = @task.job_class
    render :template => klass.view_path(params[:view])
  end

  # Delete an analysis task
  #
  # This action deletes a given analysis task and its associated files.
  #
  # @api public
  # @return [undefined]
  def task_destroy
    dataset = current_user.datasets.find(params[:id])
    raise ActiveRecord::RecordNotFound unless dataset
    redirect_to dataset and return if params[:cancel]

    task = dataset.analysis_tasks.find(params[:task_id])
    raise ActiveRecord::RecordNotFound unless task

    task.destroy
    redirect_to dataset_path
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
    raise ActiveRecord::RecordNotFound unless dataset
    task = dataset.analysis_tasks.find(params[:task_id])
    raise ActiveRecord::RecordNotFound unless task
    raise ActiveRecord::RecordNotFound unless task.result_file
    raise ActiveRecord::RecordNotFound unless File.exists?(task.result_file.filename)

    task.result_file.send_file(self)
  end

  private

  # Whitelist acceptable dataset parameters
  #
  # @return [ActionController::Parameters] acceptable parameters for
  #   mass-assignment
  def dataset_params
    params.require(:dataset).permit(:name)
  end
end
