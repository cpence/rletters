
# Display the user's workflow through RLetters
#
# We walk the user through the process of logging in, selecting an analysis
# type to run, gathering datasets, and collecting results.  This controller
# is responsible for all of that.
class WorkflowController < ApplicationController
  layout 'full_page'
  before_action :authenticate_user!, except: [:index, :image]

  # Show the introduction page or the user dashboard
  #
  # @return [void]
  def index
    @database_size = RLetters::Solr::CorpusStats.new.size || 0

    if user_signed_in?
      render 'dashboard'
    else
      render 'index'
    end
  end

  # Start running a new analysis
  #
  # @return [void]
  def start
  end

  # Destroy the currently building analysis, leaving workflow mode
  #
  # @return [void]
  def destroy
    current_user.workflow_active = false
    current_user.workflow_class = nil
    current_user.workflow_datasets.clear
    current_user.save

    redirect_to workflow_path, alert: I18n.t('workflow.destroy.success')
  end

  # Show information about a job
  #
  # @return [void]
  def info
    set_workflow_parameters
  end

  # Get the user to collect datasets for a job
  #
  # @return [void]
  def activate
    set_workflow_parameters

    # Write out the class that the user has chosen
    current_user.workflow_active = true
    current_user.workflow_class = params[:class]

    # See if we've been asked to link a dataset to this job
    if params[:link_dataset_id]
      # Actually find it, which will raise an error if it's not actually a
      # dataset that the user owns
      dataset = current_user.datasets.active.find(params[:link_dataset_id])
      current_user.workflow_datasets << dataset.to_param
    end

    # Same for unlinking a dataset
    if params[:unlink_dataset_id]
      # Check it and raise if it's a bad dataset ID
      if current_user.workflow_datasets.find_index(params[:unlink_dataset_id])
        current_user.workflow_datasets.delete(params[:unlink_dataset_id])
      else
        fail ActiveRecord::RecordNotFound
      end
    end

    # Save our changes, if any, and update the workflow parameters
    current_user.save!
    set_workflow_parameters
  end

  # Allow the user to pick up data from all of their tasks
  #
  # @return [void]
  def fetch
    analysis_criteria = {
      datasets: { user_id: current_user.to_param, disabled: false }
    }
    tasks = Datasets::Task.joins(:dataset).where(analysis_criteria)

    if params[:terminate]
      # Delete all unfinished tasks in the DB. When their jobs next call at(),
      # they will explode.
      tasks.not_finished.readonly(false).destroy_all
      redirect_to root_path, alert: I18n.t('workflow.fetch.terminate')
      return
    end

    @pending_tasks = tasks.active.order(:created_at)
    @finished_tasks = tasks.finished.order(finished_at: :desc)

    # Decorate
    @pending_tasks = TaskDecorator.decorate_collection(@pending_tasks)
    @finished_tasks = TaskDecorator.decorate_collection(@finished_tasks)

    # If this is an AJAX request, render the tasks table only
    if request.xhr?
      disable_browser_cache
      render :fetch_xhr, layout: false
    else
      render
    end
  end

  # Return one of the uploaded-asset images
  #
  # @return [void]
  def image
    model = Admin::UploadedAsset.find(params[:id])
    send_data model.file.file_contents(:original),
              filename: model.file_file_name,
              content_type: model.file_content_type
  end

  private

  # Get the current workflow details from the params
  #
  # @return [void]
  def set_workflow_parameters
    fail ActiveRecord::RecordNotFound unless params[:class]
    @klass = params[:class].safe_constantize
    fail ActiveRecord::RecordNotFound unless @klass

    @num_datasets = @klass.num_datasets
    @num_workflow_datasets = current_user.workflow_datasets.size
  end
end
