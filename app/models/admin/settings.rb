# -*- encoding : utf-8 -*-

# Singleton model class containing all of our global settings
#
# This model (via the +rails_settings_cached+ gem) is the single source for
# all of our global application settings (such as the URL for the Solr server,
# the site title, etc.).
#
# @example Get the Solr URL
#   Settings.solr_server_url
#   # => 'http://localhost:8983/solr/'
class Settings < RailsSettings::CachedSettings
	attr_accessible :var

  # A mock model for the settings
  #
  # In order to be able to edit the settings using the ActiveAdmin interface,
  # we need to have a fake model that can encapsulate each key/value pair in the
  # settings database.  That's what this class does.
  #
  # @attr [String] key Key for this setting
  # @attr [String] value Value of this setting
  class Value < Struct.new(:key, :val)
    include ActiveModel::Conversion  
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    
    # Objects of this class are not persisted in the database
    # @api private
    # @return [Boolean] false
    def persisted?; false; end
  end
end
