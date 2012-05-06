# -*- encoding : utf-8 -*-

# Representation of a library-owned OpenURL resolver
#
# @attr [String] name The name of the library
# @attr [String] url The base URL for its OpenURL resolver
# @attr [User] user The user this library entry belongs to
class Library < ActiveRecord::Base
  belongs_to :user
  
  validates :name, :presence => true
  validates :url, :presence => true
  # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
  validates :url, :format => { :with => /(?i)\b((?:[a-z][\w-]+:(?:\/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’]))/u }
  validates :user_id, :presence => true
  
  attr_accessible :url, :name

  protected
  
  after_validation do |library|
    unless library.url.blank?
      library.url = "http://" + url unless library.url.start_with? "http"
      library.url = library.url + "?" unless library.url.end_with? "?"
    end
  end
end
