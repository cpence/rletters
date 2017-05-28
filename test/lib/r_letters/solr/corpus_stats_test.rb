require 'test_helper'

class CorpusStatsTest < ActiveSupport::TestCase
  test 'works' do
    stats = RLetters::Solr::CorpusStats.new

    assert_equal 1502, stats.size
  end
end
