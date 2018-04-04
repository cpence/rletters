
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
  #   @return [Paperclip::Attachment] The asset itself
  class UploadedAsset < ApplicationRecord
    self.table_name = 'admin_uploaded_assets'
    validates :name, presence: true

    # Store these assets in the database
    has_attached_file :file, url: '/workflow/image/:id'
    validates_attachment_content_type :file, content_type: %r{\Aimage/.*\Z}

    # @return (see ApplicationRecord.admin_attributes)
    def self.admin_attributes
      {
        friendly_name: { form_options: { disabled: true } },
        file_file_name: { no_form: true },
        file_file_size: { no_form: true },
        file_content_type: { no_form: true },
        file: { no_display: true }
      }
    end

    # @return (see ApplicationRecord.admin_configuration)
    def self.admin_configuration
      { no_create: true, no_delete: true }
    end

    # @return [String] Friendly name of this asset (looked up in locale)
    def friendly_name
      ret = I18n.t("uploaded_assets.#{name}", default: '')
      return name if ret.blank?
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
end
