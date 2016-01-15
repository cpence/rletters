
module Admin
  # Decorate UploadedAsset objects
  class UploadedAssetDecorator < ApplicationRecordDecorator
    decorates Admin::UploadedAsset
    delegate_all
  end
end
