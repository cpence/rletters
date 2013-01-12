# -*- encoding : utf-8 -*-
class UploadedAsset < ActiveRecord::Base
  attr_accessible :name, :file
  has_attached_file :file, {
    # This isn't meant to enforce any kind of secrecy, it just makes for URLs
    # that are easier to read, don't expose internal server details, and should
    # cache nicely.
    :url => "/system/:hash.:extension",
    :hash_secret => "baebb86ffdab9a513daebd0d5ba9fba60b3e5339c32387444f7bf15b06ae18412376e2e8737019b6ff4c68c4863c711f97826f500ddead5c7ab78a3f5f05485b"
  }
  
  def friendly_name
    I18n.t("uploaded_assets.#{name}")
  end
  
  def self.url_for(name)
    asset = UploadedAsset.find_by_name(name) rescue nil
    return "" unless asset
    asset.file.url
  end
end
