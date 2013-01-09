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
      @@solr ||= RSolr::Ext.connect(:url => APP_CONFIG['solr_server_url'],
                                    :read_timeout => APP_CONFIG['solr_timeout'],
                                    :open_timeout => APP_CONFIG['solr_timeout'])
    end
  end  
end
