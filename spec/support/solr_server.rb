# -*- encoding : utf-8 -*-

require 'pty'

# Start and stop a bundled Solr server
module SolrServer

  def self.start
    `#{Rails.root.join('script', 'solr_start')}`
    sleep 3
  end

  def self.stop
    `#{Rails.root.join('script', 'solr_stop')}`
  end

  def self.disable
    WebMock.disable_net_connect!
    WebMock.stub_request(:any, /http:\/\/localhost:8983.*/).to_return(:body => "{}", :status => 200, :headers => { 'Content-Length' => 2 })
  end

  def self.enable
    WebMock.reset!
    WebMock.enable!
    WebMock.disable_net_connect!(:allow_localhost => true)
  end

end


module SolrServerHelper
  def break_solr
    before(:each) do
      SolrServer.disable
    end

    after(:each) do
      SolrServer.enable
    end
  end
end

