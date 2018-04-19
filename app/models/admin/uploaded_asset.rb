
module Admin
  # Images and other static assets uploaded by the administrator
  #
  # The companion to the MarkdownPage class, this class represents asset objects
  # (such as images) that need to be uploaded and customized by the site
  # administrator.
  #
  # @!attribute name
  #   @raise [RecordInvalid] if the name is missing (validates :presence)
  #   @return [String] Name of this asset (an internal key)
  # @!attribute file
  #   @return [ActiveStorage::Blob] The asset itself
  class UploadedAsset < ApplicationRecord
    self.table_name = 'admin_uploaded_assets'
    validates :name, presence: true

    # Store these assets
    has_one_attached :file

    # @return [String] Friendly name of this asset (looked up in locale)
    def friendly_name
      ret = I18n.t("uploaded_assets.#{name}", default: '')
      return name if ret.blank?
      ret
    end
  end
end
