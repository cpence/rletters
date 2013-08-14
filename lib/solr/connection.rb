# -*- encoding : utf-8 -*-
require_relative './errors'

module Solr

  # Methods for managing the singleton connection to the Solr server
  module Connection

    # The default Solr search fields
    DEFAULT_FIELDS = 'shasum,doi,license,license_url,authors,title,journal,year,volume,number,pages'

    # The default Solr search fields, with the fulltext added
    DEFAULT_FIELDS_FULLTEXT = 'shasum,doi,license,license_url,authors,title,journal,year,volume,number,pages,fulltext'

    class << self
      # Cache the connection to solr
      #
      # @return [RSolr::Client] the cached Solr connection object
      attr_accessor :solr

      # Cache the URL to Solr, to detect changes in the configuration panel
      #
      # @return [String] the URL for connecting to Solr
      attr_accessor :url
    end

    # Get a response from Solr
    #
    # This method breaks out the retrieval of a Solr response in order to
    # provide for easier testing.
    #
    # @api public
    # @param [Hash] params
    # @option params [Integer] :start offset within the result set at which
    #   to begin returning documents
    # @option params [Integer] :rows maximum number of results to return
    # @option params [String] :sort sorting string ('<method> <direction>')
    #
    # @return [Solr::SearchResult] Solr search result
    def self.search(params)
      get_solr

      SearchResult.new(Connection.solr.find('search', params))
    rescue StandardError => e
      Rails.logger.warn "Connection to Solr failed: #{e.inspect}"
      err = RSolr::Ext::Response::Base.new({ 'response' => { 'docs' => [] } },
                                           'search', params)
      SearchResult.new(err)
    end

    # Get the info/statistics hash from Solr
    #
    # This method retrieves information about the Solr server, including the
    # Solr and Java versions.
    #
    # @api private
    # @return [Hash] Unprocessed Solr response
    def self.info
      get_solr
      Connection.solr.get 'admin/system'
    rescue StandardError => e
      Rails.logger.warn "Connection to Solr failed: #{e.inspect}"
      {}
    end

    private

    # Retrieve the Solr connection object
    #
    # Since the Solr connection URL can be updated on the fly using the
    # administration console, this method has to watch the value of that URL
    # and reconnect to Solr when required.
    #
    # @api private
    # @return [RSolr::Client] Solr connection object
    def self.get_solr
      Connection.solr ||= RSolr::Ext.connect(
        url: Setting.solr_server_url,
        read_timeout: Setting.solr_timeout.to_i,
        open_timeout: Setting.solr_timeout.to_i
      )

      # Make sure that we update the Solr connection when we change the
      # Solr URL, since it can be dynamically modified in the admin panel
      Connection.url ||= Setting.solr_server_url
      if Connection.url != Setting.solr_server_url
        Connection.url = Setting.solr_server_url

        Connection.solr = RSolr::Ext.connect(
          url: Setting.solr_server_url,
          read_timeout: Setting.solr_timeout.to_i,
          open_timeout: Setting.solr_timeout.to_i
        )
      end
    end
  end
end
