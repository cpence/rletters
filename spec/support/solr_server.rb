# -*- encoding : utf-8 -*-

# Break the Solr server by stubbing it out using WebMock, to simulate errors.
module SolrServer

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

