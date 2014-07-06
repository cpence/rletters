# -*- encoding : utf-8 -*-

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
#   @return [Paperclip::Attachment] The asset itself
class Admin::UploadedAsset < ActiveRecord::Base
  self.table_name = 'admin_uploaded_assets'
  validates :name, presence: true

  # Store these assets in the database
  has_attached_file :file,
                    database_table: 'admin_uploaded_asset_files',
                    url: '/workflow/image/:id?style=:style'
  validates_attachment :file,
                       content_type: { content_type: %w(image/png
                                                        image/jpeg
                                                        image/jpg
                                                        image/x-icon) }

  # @return [String] Friendly name of this asset (looked up in locale)
  def friendly_name
    ret = I18n.t("uploaded_assets.#{name}", default: '')
    return name if ret == ''
    ret
  end

  # Get the URL that points to a given asset
  #
  # @param [String] name The asset to look up
  # @return [String] The URL for the given asset name (or blank)
  def self.url_for(name)
    asset = Admin::UploadedAsset.find_by(name: name)
    return '' unless asset

    asset.file.url
  end
end
