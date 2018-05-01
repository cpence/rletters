
module Admin
  class CategoriesController < ApplicationController
    before_action :authenticate_admin!

    # Show a list of uploaded assets
    #
    # @return [void]
    def index
    end

    # Replace an Admin::UploadedAsset with the uploaded file
    #
    # @return [void]
    def upload
      fail ActionController::ParameterMissing, :file unless params[:file]
      asset = Admin::UploadedAsset.find(params[:id])

      asset.file.purge
      asset.file.attach(params[:file])
      asset.file.save

      redirect_to assets_path
    end
  end
end
