# -*- encoding : utf-8 -*-

module Solr
  # Exception thrown on failure to connect to Solr
  class ConnectionError < RuntimeError; end

  # Methods for managing the singleton connection to the Solr server
  module Connection
    # The default Solr search fields
    DEFAULT_FIELDS = 'uid,doi,license,license_url,data_source,authors,title,journal,year,volume,number,pages,fulltext_url'

    # The default Solr search fields, with the fulltext added
    DEFAULT_FIELDS_FULLTEXT = 'uid,doi,license,license_url,data_source,authors,title,journal,year,volume,number,pages,fulltext_url,fulltext'

    # Exceptions that can be raised by the Solr connection
    EXCEPTIONS = Net::HTTP::EXCEPTIONS + [
      RSolr::Error::Http,
      RSolr::Error::InvalidRubyResponse,
      Solr::ConnectionError
    ]

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
      # We actually have to do this manually to make POST-parameters work
      # right, instead of calling rsolr-ext's #find method.
      raw_response = search_raw(params)

      # Fix with a reasonable default if broken
      if raw_response.empty?
        raw_response = {
          'response' => {
            'docs' => []
          }
        }
      end

      SearchResult.new(RSolr::Ext::Response::Base.new(raw_response,
                                                      'search',
                                                      params))
    end

    # Get a raw hash response from Solr
    #
    # Sometimes we don't want a cleaned up result, so just get the raw hash.
    #
    # @api public
    # @param [Hash] params Solr query parameters
    # @return [Hash] Solr search result, unprocessed
    def self.search_raw(params)
      get_solr
      camelize_params!(params)

      Connection.solr.post 'search', data: params
    rescue *Solr::Connection::EXCEPTIONS => e
      Rails.logger.warn "Connection to Solr failed: #{e.inspect}"
      Rails.logger.info "Query for failed connection: #{params.to_s}"
      {}
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
    rescue *Solr::Connection::EXCEPTIONS => e
      Rails.logger.warn "Connection to Solr failed: #{e.inspect}"
      {}
    end

    # Ping the Solr server
    #
    # Returns the latency of the connection, or +nil+ if there is a connection
    # failure.
    #
    # @return [Integer] latency of Solr connection
    # @example Get the Solr latency
    #   Solr::Connection.ping
    #   # => 6
    def self.ping
      get_solr
      Connection.solr.get('admin/ping')['responseHeader']['QTime']
    rescue *Solr::Connection::EXCEPTIONS
      nil
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
        url: Admin::Setting.solr_server_url,
        read_timeout: Admin::Setting.solr_timeout.to_i,
        open_timeout: Admin::Setting.solr_timeout.to_i
      )

      # Make sure that we update the Solr connection when we change the
      # Solr URL, since it can be dynamically modified in the admin panel
      Connection.url ||= Admin::Setting.solr_server_url
      if Connection.url != Admin::Setting.solr_server_url
        Connection.url = Admin::Setting.solr_server_url

        Connection.solr = RSolr::Ext.connect(
          url: Admin::Setting.solr_server_url,
          read_timeout: Admin::Setting.solr_timeout.to_i,
          open_timeout: Admin::Setting.solr_timeout.to_i
        )
      end
    end

    # Convert some parameters
    #
    # We want to allow users to pass 'Ruby-esque' symbols to this class, so
    # coerce all of the parameter keys to Java-style 'lowerCamelCase' here.
    def self.camelize_params!(params)
      params.keys.each do |k|
        if k.to_s.include? '_'
          params[k.to_s.camelize(:lower)] = params.delete(k)
        end
      end
    end
  end
end
