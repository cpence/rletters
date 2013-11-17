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
  before_action :authenticate_user!

  # Show all of the current user's datasets
  # @api public
  # @return [undefined]
  def index
    @datasets = current_user.datasets.active

    # If this is an AJAX request, render the dataset table only
    if request.xhr?
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
  # @api public
  # @return [undefined]
  def show
    @dataset = current_user.datasets.active.find(params[:id])

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
    dataset = current_user.datasets.create(name: dataset_params[:name],
                                           disabled: true)

    Resque.enqueue(Jobs::CreateDataset,
                   user_id: current_user.to_param,
                   dataset_id: dataset.to_param,
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
    @dataset.disabled = true
    @dataset.save

    Resque.enqueue(Jobs::DestroyDataset,
                   user_id: current_user.to_param,
                   dataset_id: @dataset.to_param)

    redirect_to datasets_path
  end

  # Add a single document to a dataset
  #
  # This is an odd update method.  The only attribute that we allow you to send
  # in here is the UID of a single document to be added into the dataset.
  # Any other attempts to PATCH dataset attributes will be silently ignored.
  #
  # @api public
  # @return [undefined]
  def update
    fail ActionController::ParameterMissing.new(:uid) unless params[:uid]

    @dataset = current_user.datasets.active.find(params[:id])
    @document = Document.find(params[:uid])

    # Set the fetch flag if required
    if @document.fulltext_url
      @dataset.fetch = true
      @dataset.save
    end

    # No reason for this to be a delayed job, just do the create
    @dataset.entries.create({ uid: params[:uid] })
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
