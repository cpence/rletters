
module Admin
  class StopListsController < ApplicationController
    before_action :authenticate_admin!

    # Show the stop list creation form
    #
    # @return [void]
    def new
      @stop_list = Documents::StopList.new

      render layout: false
    end

    # Create a new stop list
    #
    # @return [void]
    def create
      list = Documents::StopList.create(stop_list_params)
      if list.save
        redirect_to stop_lists_path
      else
        redirect_to stop_lists_path, alert: I18n.t('admin.stop_lists.validation_error')
      end
    end

    # Show the edit form for an existing stop list
    #
    # @return [void]
    def edit
      @stop_list = Documents::StopList.find(params[:id])

      render layout: false
    end

    # Update the parameters of an existing stop list
    #
    # @return [void]
    def update
      list = Documents::StopList.find(params[:id])
      list.update!(stop_list_params)
      redirect_to stop_lists_path
    end

    # Delete an individual stop list
    #
    # @return [void]
    def destroy
      list = Documents::StopList.find(params[:id])
      list.destroy()

      redirect_to stop_lists_path
    end

    private

    # Whitelist acceptable stop list parameters
    #
    # @return [ActionController::Parameters] acceptable parameters for
    #   mass-assignment
    def stop_list_params
      params.require(:documents_stop_list).permit(:language, :list)
    end
  end
end
