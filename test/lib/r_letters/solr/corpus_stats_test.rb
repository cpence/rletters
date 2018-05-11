# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Solr
    class CorpusStatsTest < ActiveSupport::TestCase
      test 'works' do
        stats = RLetters::Solr::CorpusStats.new

        assert_equal 1501, stats.size
      end
    end
  end
end
