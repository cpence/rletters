# -*- encoding : utf-8 -*-

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
  # @api public
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
  # @api public
  # @return [void]
  def start
  end

  # Destroy the currently building analysis, leaving workflow mode
  #
  # @api public
  # @return [void]
  def destroy
    current_user.workflow_active = false
    current_user.workflow_class = nil
    current_user.workflow_datasets = nil
    current_user.save

    redirect_to workflow_path, alert: I18n.t('workflow.destroy.success')
  end

  # Show information about a job
  #
  # @api public
  # @return [void]
  def info
    set_workflow_parameters
  end

  # Get the user to collect datasets for a job
  #
  # @api public
  # @return [void]
  def activate
    set_workflow_parameters

    # Write out the class that the user has chosen
    current_user.workflow_active = true
    current_user.workflow_class = params[:class]

    # See if we've been asked to link a dataset to this job
    if params[:link_dataset_id]
      dataset = current_user.datasets.active.find(params[:link_dataset_id])

      current_user.workflow_datasets ||= []
      current_user.workflow_datasets << dataset
    end

    # Same for unlinking a dataset
    if params[:unlink_dataset_id]
      current_user.workflow_datasets.delete_if do |d|
        d.to_param == params[:unlink_dataset_id]
      end
    end

    # Save our changes, if any
    current_user.save
  end

  # Allow the user to pick up data from all of their analysis tasks
  #
  # @api public
  # @return [void]
  def fetch
    analysis_criteria = {
      datasets: { user_id: current_user.to_param, disabled: false }
    }
    tasks = Datasets::AnalysisTask.joins(:dataset).where(analysis_criteria)

    @pending_tasks = tasks.where(finished_at: nil).order(:created_at)
    @finished_tasks = tasks.where.not(finished_at: nil).order(finished_at: :desc)

    if params[:terminate]
      # Try to knock any currently running analysis tasks for this user out
      # of the queue (if we're not running inline)
      unless Resque.inline
        @pending_tasks.each do |t|
          status = Resque::Plugins::Status::Hash.get(t.resque_key)
          next unless status

          # Don't touch completed tasks, should they make it here
          next if status.completed?

          if status.working?
            # Signal the job to terminate the next time it calls at() or tick()
            Resque::Plugins::Status::Hash.kill(t.resque_key)
          elsif status.failed? || status.killed?
            # Just delete the record; we've already got a failed/killed job
            Resque::Plugins::Status::Hash.remove(t.resque_key)
          else
            # Pull from the queue and delete
            t.job_class.dequeue(t.job_class, t.resque_key)
            Resque::Plugins::Status::Hash.remove(t.resque_key)
          end
        end
      end

      # Delete all tasks in the DB
      @pending_tasks.readonly(false).destroy_all

      redirect_to root_path, alert: I18n.t('workflow.fetch.terminate')
      return
    end

    # Decorate
    @pending_tasks = AnalysisTaskDecorator.decorate_collection(@pending_tasks)
    @finished_tasks = AnalysisTaskDecorator.decorate_collection(@finished_tasks)

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
  # @api public
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
  # @api private
  # @return [void]
  def set_workflow_parameters
    fail ActiveRecord::RecordNotFound unless params[:class]
    @klass = ('Jobs::Analysis::' + params[:class]).safe_constantize
    fail ActiveRecord::RecordNotFound unless @klass

    @num_datasets = @klass.num_datasets
  end
end
