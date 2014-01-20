# -*- encoding : utf-8 -*-

module Solr
  # Methods that help us process inbound data from Solr
  #
  # A handful of operations are so commonly performed on a dataset that we
  # abstract them here to increase code reuse and give us an opportunity to
  # optimize our interactions with the Solr server.
  module DataHelpers
    include DataHelpers::CountByField
  end
end
