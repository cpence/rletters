# frozen_string_literal: true

module Admin
  # Images and other static assets uploaded by the administrator
  #
  # The companion to the Snippet class, this class represents asset objects
  # (such as images) that need to be uploaded and customized by the site
  # administrator.
  #
  # @!attribute name
  #   @raise [RecordInvalid] if the name is missing (validates :presence)
  #   @return [String] Name of this asset (an internal key)
  # @!attribute file
  #   @return [ActiveStorage::Blob] The asset itself
  class Asset < ApplicationRecord
    self.table_name = 'admin_assets'
    validates :name, presence: true

    # Store these assets
    has_one_attached :file

    # @return [String] Friendly name of this asset (looked up in locale)
    def friendly_name
      ret = I18n.t("assets.#{name}", default: '')
      return name if ret.blank?
      ret
    end

    # Returns true if an asset by that name is both present and attached
    #
    # @return [Boolean] true if this asset can be used
    def self.usable?(name)
      asset = find_by(name: name)
      asset&.file&.attached?
    end
  end
end
