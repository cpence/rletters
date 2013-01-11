# -*- encoding : utf-8 -*-

module Solr
  module Connection
    
    # Get a response from Solr
    #
    # This method breaks out the retrieval of a Solr response in order to
    # provide for easier testing.
    #
    # @api private
    # @param [Hash] params
    # @return [RSolr::Ext.response] Solr search result
    def self.find(params)
      begin
        get_solr
        ret = @@solr.find params
      rescue Exception => e
        Rails.logger.warn "Connection to Solr failed: #{e.inspect}"
        RSolr::Ext::Response::Base.new({ 'response' => { 'docs' => [] } }, 'select', params)
      end
    end
    
    def self.info
      begin
        get_solr
        ret = @@solr.get 'admin/system'
      rescue Exception => e
        Rails.logger.warn "Connection to Solr failed: #{e.inspect}"
        {}
      end
    end
    
    private
    
    def self.get_solr
      @@solr ||= RSolr::Ext.connect(:url => Settings.solr_server_url,
                                    :read_timeout => Settings.solr_timeout.to_i,
                                    :open_timeout => Settings.solr_timeout.to_i)
      
      # Make sure that we update the Solr connection when we change the
      # Solr URL, since it can be dynamically modified in the admin panel
      @@url ||= Settings.solr_server_url
      if @@url != Settings.solr_server_url
        @@url = Settings.solr_server_url
        
        @@solr = RSolr::Ext.connect(:url => Settings.solr_server_url,
                                    :read_timeout => Settings.solr_timeout.to_i,
                                    :open_timeout => Settings.solr_timeout.to_i)
      end
    end
  end  
end
