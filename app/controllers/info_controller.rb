# -*- encoding : utf-8 -*-

# Display static information pages about RLetters
#
# This controller displays static information, such as the RLetters help, FAQ,
# and privacy policy.
class InfoController < ApplicationController

  # Query some Solr parameters for the index page
  #
  # This action will query the Solr database to get some nice statistics
  # for our index page.
  #
  # @api public
  # @return [undefined]
  def index
    solr_query = { q: '*:*',
                   qt: 'precise',
                   rows: 1,
                   start: 0 }
    begin
      search_result = Solr::Connection.find solr_query
      @database_size = search_result.num_hits
    rescue StandardError
      @database_size = 0
    end
  end

  # Show the about page
  #
  # @api public
  # @return [undefined]
  def about; end

  # Show the FAQ
  #
  # @api public
  # @return [undefined]
  def faq; end

  # Show the privacy policy
  #
  # @api public
  # @return [undefined]
  def privacy; end

  # Show the tutorial
  #
  # @api public
  # @return [undefined]
  def tutorial; end
end
