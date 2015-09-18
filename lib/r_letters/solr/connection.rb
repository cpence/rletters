
# The module containing all domain-specific logic for RLetters
module RLetters
  # Code that connects RLetters to a Solr server and parses its responses
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
        RLetters::Solr::ConnectionError
      ]

      # Get a response from Solr
      #
      # This method breaks out the retrieval of a Solr response in order to
      # provide for easier testing.
      #
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
      # @param [Hash] params Solr query parameters
      # @return [Hash] Solr search result, unprocessed
      def self.search_raw(params)
        ensure_connected!
        camelize_params!(params)

        # We have a different destination if term vectors are enabled
        dest = params[:tv] ? 'termvectors' : 'search'

        Thread.current[:solr_handle].post dest, data: params
      rescue *EXCEPTIONS => e
        Rails.logger.warn "Connection to Solr failed: #{e.inspect}"
        Rails.logger.info "Query for failed connection: #{Thread.current[:solr_url]}: #{params}"
        {}
      end

      # Get the info/statistics hash from Solr
      #
      # This method retrieves information about the Solr server, including the
      # Solr and Java versions.
      #
      # @return [Hash] Unprocessed Solr response
      def self.info
        ensure_connected!
        Thread.current[:solr_handle].get 'admin/system'
      rescue *EXCEPTIONS => e
        Rails.logger.warn "Connection to Solr failed: #{e.inspect}"
        {}
      end

      # Ping the Solr server
      #
      # Returns the latency of the connection, or +nil+ if there is a connection
      # failure.
      #
      # @return [Integer] latency of Solr connection
      def self.ping
        ensure_connected!

        result = search_raw(q: '*:*',
                            def_type: 'lucene',
                            start: 0,
                            rows: 0)

        return nil if !result || result.empty?
        result ['responseHeader']['QTime']
      end

      private

      # Retrieve the Solr connection object
      #
      # Since the Solr connection URL can be updated on the fly using the
      # administration console, this method has to watch the value of that URL
      # and reconnect to Solr when required.
      #
      # @return [void]
      def self.ensure_connected!
        Thread.current[:solr_url] ||= Admin::Setting.solr_server_url
        Thread.current[:solr_handle] ||= connect

        # Make sure that we update the Solr connection when we change the
        # Solr URL, since it can be dynamically modified in the admin panel
        if Thread.current[:solr_url] != Admin::Setting.solr_server_url
          Thread.current[:solr_url] = Admin::Setting.solr_server_url
          Thread.current[:solr_handle] = connect
        end
      end

      # Make the actual Solr connection
      #
      # Read the appropriate settings and connect to the Solr server
      #
      # @return [RSolr::Client] the Solr connection object
      def self.connect
        RSolr::Ext.connect(
          url: Admin::Setting.solr_server_url,
          read_timeout: Admin::Setting.solr_timeout.to_i,
          open_timeout: Admin::Setting.solr_timeout.to_i
        )
      end

      # Convert some parameters
      #
      # We want to allow users to pass 'Ruby-esque' symbols to this class, so
      # coerce all of the parameter keys to Java-style 'lowerCamelCase' here.
      #
      # @param [Hash] params the parameters to convert
      # @return [Hash] those parameters, converted from snake_case to camelCase
      def self.camelize_params!(params)
        params.keys.each do |k|
          if k.to_s.include? '_'
            params[k.to_s.camelize(:lower)] = params.delete(k)
          end
        end
      end
    end
  end
end
