# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Solr::DataHelpers::CorpusSize do

  describe '.corpus_size' do
    it 'works' do
      expect(Solr::DataHelpers.corpus_size).to eq(1043)
    end
  end

end
