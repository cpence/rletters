# frozen_string_literal: true
require 'test_helper'

class RLetters::Solr::CorpusStatsTest < ActiveSupport::TestCase
  test 'works' do
    stats = RLetters::Solr::CorpusStats.new

    assert_equal 1502, stats.size
  end
end
