
# Helper methods for stubbing out HTTP queries
module StubConnection
  def stub_connection(url_or_regex, file)
    path = Rails.root.join('spec', 'support', 'requests', "#{file}.curl")
    stub_request(:get, url_or_regex).to_return(IO.read(path))
  end
end
