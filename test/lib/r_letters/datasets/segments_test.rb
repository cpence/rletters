# frozen_string_literal: true
require 'test_helper'

class RLetters::Datasets::SegmentsTest < ActiveSupport::TestCase
  test 'should report progress' do
    called_sub_100 = false
    called_100 = false

    RLetters::Datasets::Segments.new(dataset: create(:full_dataset, num_docs: 10),
                                     progress: lambda do |p|
                                       if p < 100
                                         called_sub_100 = true
                                       else
                                         called_100 = true
                                       end
                                     end).segments

    assert called_sub_100
    assert called_100
  end

  test 'with one dataset block, splitting across, it works' do
    analyzer = RLetters::Datasets::Segments.new(dataset: create(:full_dataset, num_docs: 10))
    segments = analyzer.segments

    assert_equal 1, segments.size
    assert_equal 4803, segments[0].words.size
    assert_equal 'Block #1/1', segments[0].name
    assert_equal 8, analyzer.dfs['disease']
    assert_equal 1104, analyzer.corpus_dfs['disease']
  end

  test 'with one block per document, not splitting across, it works' do
    analyzer = RLetters::Datasets::Segments.new(dataset: create(:full_dataset, num_docs: 10),
                                                split_across: false)
    segments = analyzer.segments

    assert_equal 10, segments.size
    assert segments[0].name.start_with?("Block #1/1 (within ‘doi:10.")
    assert_equal 8, analyzer.dfs['disease']
    assert_equal 1104, analyzer.corpus_dfs['disease']
  end

  test 'with five total blocks, splitting across, it works' do
    analyzer = RLetters::Datasets::Segments.new(dataset: create(:full_dataset, num_docs: 10),
                                                num_blocks: 5)
    segments = analyzer.segments

    assert_equal 5, segments.size
    assert_equal [961, 961, 961, 960, 960], segments.map(&:words).map(&:size)
    assert_equal 'Block #1/5', segments[0].name
    assert_equal 8, analyzer.dfs['disease']
    assert_equal 1104, analyzer.corpus_dfs['disease']
  end

  test 'with truncate_all, splitting across, it works' do
    analyzer = RLetters::Datasets::Segments.new(dataset: create(:full_dataset, num_docs: 10),
                                                block_size: 10,
                                                last_block: :truncate_all)
    segments = analyzer.segments

    assert_equal 1, segments.size
    assert_equal 10, segments[0].words.size
    assert_equal 'Block #1 of 10 words', segments[0].name
    assert_equal 8, analyzer.dfs['disease']
    assert_equal 1104, analyzer.corpus_dfs['disease']
  end

  test 'with truncate_all, not splitting across, it works' do
    analyzer = RLetters::Datasets::Segments.new(dataset: create(:full_dataset, num_docs: 10),
                                                split_across: false,
                                                block_size: 10,
                                                last_block: :truncate_all)
    segments = analyzer.segments

    assert_equal 10, segments.size
    assert_equal 10, segments[0].words.size
    assert_equal 10, segments[1].words.size
    assert segments[0].name.start_with?("Block #1 of 10 words (within ‘doi:10.")
    assert_equal 8, analyzer.dfs['disease']
    assert_equal 1104, analyzer.corpus_dfs['disease']
  end
end
