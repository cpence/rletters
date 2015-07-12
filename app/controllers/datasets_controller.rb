
# Display, modify, delete, and analyze datasets belonging to a given user
#
# This controller is responsible for the handling of the datasets which
# belong to a given user.  It displays the user's list of datasets, and
# handles the starting and management of the user's background analysis
# tasks.
#
# @see Dataset
class DatasetsController < ApplicationController
  before_action :authenticate_user!

  # Show all of the current user's datasets
  #
  # @return [void]
  def index
    @datasets = current_user.datasets.active

    # If this is an AJAX request, render the dataset table only
    if request.xhr?
      disable_browser_cache
      render :index_xhr, layout: false
    else
      render
    end
  end

  # Show information about the requested dataset
  #
  # This action also includes links for users to perform various analysis
  # tasks on the dataset.
  #
  # @return [void]
  def show
    @dataset = current_user.datasets.active.find(params[:id])

    # Clear failed tasks if requested
    return unless params[:clear_failed]
    return if @dataset.tasks.failed.size == 0

    @dataset.tasks.failed.destroy_all
    flash[:notice] = t('datasets.show.deleted')
  end

  # Show the form for creating a new dataset
  #
  # @return [void]
  def new
    @dataset = current_user.datasets.build
    render layout: false
  end

  # Create a new dataset in the database
  #
  # @return [void]
  def create
    dataset = current_user.datasets.create(name: dataset_params[:name],
                                           disabled: true)

    Resque.enqueue(Jobs::CreateDataset, current_user.to_param,
                   dataset.to_param, params[:q], params[:fq],
                   params[:def_type])

    if current_user.workflow_active
      redirect_to workflow_activate_path(current_user.workflow_class),
                  flash: { success: I18n.t('datasets.create.building_workflow') }
    else
      redirect_to datasets_path,
                  flash: { success: I18n.t('datasets.create.building') }
    end
  end

  # Delete a dataset from the database
  #
  # @return [void]
  def destroy
    @dataset = current_user.datasets.find(params[:id])
    @dataset.disabled = true
    @dataset.save

    Resque.enqueue(Jobs::DestroyDataset, current_user.to_param,
                   @dataset.to_param)

    redirect_to datasets_path
  end

  # Add a single document to a dataset
  #
  # This is an odd update method.  The only attribute that we allow you to send
  # in here is the UID of a single document to be added into the dataset.
  # Any other attempts to PATCH dataset attributes will be silently ignored.
  #
  # @return [void]
  def update
    fail ActionController::ParameterMissing, :uid unless params[:uid]

    @dataset = current_user.datasets.active.find(params[:id])
    @document = Document.find(params[:uid])

    # Set the fetch flag if required
    if @document.fulltext_url
      @dataset.fetch = true
      @dataset.save
    end

    # No reason for this to be a delayed job, just do the create
    @dataset.entries.create(uid: params[:uid])
    redirect_to dataset_path(@dataset)
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
