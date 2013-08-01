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
class UploadedAsset < ActiveRecord::Base
  validates :name, presence: true

  has_attached_file :file, {
    # This isn't meant to enforce any kind of secrecy, it just makes for URLs
    # that are easier to read, don't expose internal server details, and should
    # cache nicely.
    url: "/system/:hash.:extension",
    hash_secret: "baebb86ffdab9a513daebd0d5ba9fba60b3e5339c32387444f7bf15b06ae18412376e2e8737019b6ff4c68c4863c711f97826f500ddead5c7ab78a3f5f05485b"
  }

  # @return [String] Friendly name of this asset (looked up in locale)
  def friendly_name
    ret = I18n.t("uploaded_assets.#{name}", default: '')
    return name if ret == ''
    ret
  end

  # @param [String] name The asset to look up
  # @return [String] The URL for the given asset name (or blank)
  def self.url_for(name)
    asset = UploadedAsset.find_by_name(name) rescue nil
    return "" unless asset
    asset.file.url
  end
end
