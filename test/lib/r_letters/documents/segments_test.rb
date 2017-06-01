require 'test_helper'

class SegmentsTest < ActiveSupport::TestCase
  setup do
    # Just always return the same document stub
    @doc = build(:full_document)
    flexmock(Document, find_by!: @doc)
  end

  test 'with no options' do
    segmenter = RLetters::Documents::Segments.new
    segmenter.add(@doc.uid)
    blocks = segmenter.blocks

    assert_equal 1, blocks.size
    assert_equal 'Block #1/1', blocks[0].name

    assert_equal @doc.fulltext.split.count, blocks[0].words.size
    assert_equal %w(it was the best of), blocks[0].words.take(5)

    assert_equal 1486, segmenter.corpus_dfs['it']
  end

  test 'creating a single block' do
    segmenter = RLetters::Documents::Segments.new(num_blocks: 1)
    segmenter.add(@doc.uid)
    blocks = segmenter.blocks

    assert_equal 1, blocks.size
    assert_equal 'Block #1/1', blocks[0].name

    assert_equal @doc.fulltext.split.size, blocks[0].words.size
    assert_equal %w(it was the best of), blocks[0].words.take(5)

    assert_includes segmenter.words_for_last, 'it'
    assert_includes segmenter.words_for_last, 'was'

    assert_equal 1486, segmenter.corpus_dfs['it']
  end

  test 'creating multiple blocks' do
    segmenter = RLetters::Documents::Segments.new(num_blocks: 5)
    segmenter.add(@doc.uid)
    blocks = segmenter.blocks

    assert_equal 5, blocks.size
    assert_equal 'Block #1/5', blocks[0].name

    assert_equal [24, 24, 24, 24, 23], blocks.map(&:words).map(&:size)

    assert_includes segmenter.words_for_last, 'it'
    assert_includes segmenter.words_for_last, 'was'

    assert_equal 1486, segmenter.corpus_dfs['it']
  end

  test 'invalid last_block acts like big_last' do
    segmenter = RLetters::Documents::Segments.new(block_size: 3,
                                                  last_block: :purple)
    segmenter.add(@doc.uid)
    blocks = segmenter.blocks

    assert_equal (@doc.fulltext.split.size.to_f / 3.0).floor, blocks.size
  end

  test 'creating word-size blocks, big_last' do
    segmenter = RLetters::Documents::Segments.new(block_size: 3,
                                                  last_block: :big_last)
    segmenter.add(@doc.uid)
    blocks = segmenter.blocks

    assert_equal (@doc.fulltext.split.size.to_f / 3.0).floor, blocks.size
    assert_equal 'Block #1 of 3 words', blocks[0].name
    assert_equal %w(it was the), blocks.first.words

    assert blocks.last.words.count > 3

    assert_equal 1486, segmenter.corpus_dfs['it']
  end

  test 'creating word-size blocks, small_last' do
    segmenter = RLetters::Documents::Segments.new(block_size: 3,
                                                  last_block: :small_last)
    segmenter.add(@doc.uid)
    blocks = segmenter.blocks

    assert_equal (@doc.fulltext.split.count / 3.0).ceil, blocks.size
    assert_equal 'Block #1 of 3 words', blocks[0].name
    assert_equal %w(it was the), blocks.first.words

    assert blocks.last.words.count < 3

    assert_equal 1486, segmenter.corpus_dfs['it']
  end

  test 'creating word-size blocks, truncate_last' do
    segmenter = RLetters::Documents::Segments.new(block_size: 3,
                                                  last_block: :truncate_last)
    segmenter.add(@doc.uid)
    blocks = segmenter.blocks

    assert_equal (@doc.fulltext.split.count / 3.0).floor, blocks.size
    assert_equal 'Block #1 of 3 words', blocks[0].name
    assert_equal %w(it was the), blocks.first.words

    assert_equal 3, blocks.last.words.count

    assert_equal 1486, segmenter.corpus_dfs['it']
  end

  test 'creating word-size blocks, truncate_all' do
    segmenter = RLetters::Documents::Segments.new(block_size: 3,
                                                  last_block: :truncate_all)
    segmenter.add(@doc.uid)
    blocks = segmenter.blocks

    assert_equal 1, blocks.size
    assert_equal 'Block #1 of 3 words', blocks[0].name
    assert_equal %w(it was the), blocks.first.words

    assert_equal 1486, segmenter.corpus_dfs['it']
  end

  test 'reset scrubs all the parameters' do
    segmenter = RLetters::Documents::Segments.new
    segmenter.add(@doc.uid)
    segmenter.blocks

    segmenter.reset!
    new_blocks = segmenter.blocks

    assert_empty new_blocks
  end
end
