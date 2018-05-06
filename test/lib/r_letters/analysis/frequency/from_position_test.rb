# frozen_string_literal: true
require 'test_helper'

class RLetters::Analysis::Frequency::FromPositionTest < ActiveSupport::TestCase
  test 'basic onegram analysis, saves blocks' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false)

    assert_kind_of Array, analyzer.blocks
    assert_kind_of Hash, analyzer.blocks[0]
    assert_kind_of String, analyzer.blocks[0].first[0]
    assert_kind_of Integer, analyzer.blocks[0].first[1]

    refute_nil analyzer.num_dataset_types
    refute_nil analyzer.num_dataset_tokens
  end

  test 'basic onegram analysis, analyzes every word' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false)

    assert_equal analyzer.num_dataset_types, analyzer.blocks.flat_map(&:keys).uniq.count
  end

  test 'basic onegram analysis, only returns words with hits' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false)

    analyzer.blocks.each do |b|
      b.values.each do |v|
        refute_equal 0, v
      end
    end
  end

  test 'basic onegram analysis, stats works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false)

    refute_nil analyzer.block_stats[0][:name]
    assert_equal analyzer.block_stats[0][:types], analyzer.blocks[0].size
    refute_nil analyzer.block_stats[0][:tokens]
  end

  test 'basic onegram analysis, tf_in_dataset works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10))

    analyzer.word_list.each do |w|
      assert_equal analyzer.blocks[0][w], analyzer.tf_in_dataset[w]
    end
  end

  test 'basic onegram analysis, df_in_dataset works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false)

    analyzer.word_list.each do |w|
      refute_nil analyzer.df_in_dataset[w]
    end

    assert_equal 1, analyzer.df_in_dataset['malaria']
    assert_equal 8, analyzer.df_in_dataset['disease']
  end

  test 'basic onegram analysis, df_in_corpus works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false)

    analyzer.word_list.each do |w|
      refute_nil analyzer.df_in_corpus[w]
    end

    assert_equal 128, analyzer.df_in_corpus['malaria']
    assert_equal 1104, analyzer.df_in_corpus['disease']
  end

  test 'progress reporting works' do
    called_sub_100 = false
    called_100 = false

    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false,
      progress: lambda do |p|
        if p < 100
          called_sub_100 = true
        else
          called_100 = true
        end
      end)

    assert called_sub_100
    assert called_100
  end

  test 'raises if num_words is negative' do
    assert_raises(ArgumentError) do
      RLetters::Analysis::Frequency::FromPosition.call(
        dataset: create(:full_dataset, num_docs: 10),
        split_across: false,
        num_words: -1,
        num_blocks: 1)
    end
  end

  test 'num_words works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false,
      num_words: 10)

    assert_equal 10, analyzer.blocks.flat_map(&:keys).uniq.count
  end

  test 'all overrides num_words' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false,
      num_words: 3,
      all: true)

    assert_equal analyzer.num_dataset_types, analyzer.blocks.flat_map(&:keys).uniq.count
  end

  test 'basic onegram analysis, inclusion_list works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      inclusion_list: 'malaria disease')

    assert_equal %w(disease malaria), analyzer.blocks[0].keys.sort
  end

  test '3-gram analysis, inclusion_list works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      ngrams: 3,
      inclusion_list: 'malaria')

    refute_empty analyzer.blocks[0]
    analyzer.blocks[0].keys.each do |k|
      assert_includes k.split, 'malaria'
    end
  end

  test 'basic onegram analysis, exclusion_list works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false,
      exclusion_list: 'a the')

    refute_empty analyzer.blocks[0]
    refute_includes analyzer.blocks[0].keys, 'a'
    refute_includes analyzer.blocks[0].keys, 'the'
  end

  test '3-gram analysis, exclusion_list works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      ngrams: 3,
      exclusion_list: 'diseases')

    analyzer.blocks[0].keys.each do |k|
      refute_includes k.split, 'diseases'
    end
  end

  test 'with n-grams and both inclusion and exclusion lists' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      ngrams: 3,
      inclusion_list: 'decade',
      exclusion_list: 'remains')

    analyzer.blocks[0].keys.each do |k|
      assert_includes k.split, 'decade'
      refute_includes k.split, 'remains'
    end
  end

  test 'with n-grams and both inclusion and stop list' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      ngrams: 3,
      inclusion_list: 'decade',
      stop_list: create(:stop_list))

    analyzer.blocks[0].keys.each do |k|
      w = k.split

      assert_includes w, 'decade'
      refute_includes w, 'a'
      refute_includes w, 'the'
      refute_includes w, 'an'
    end
  end

  test 'basic onegram analysis, stop_list works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      stop_list: create(:stop_list))

    refute_includes analyzer.blocks[0].keys, 'a'
    refute_includes analyzer.blocks[0].keys, 'the'
    refute_empty analyzer.blocks[0].keys
  end

  test 'basic onegram analysis, word_list works' do
    analyzer = RLetters::Analysis::Frequency::FromPosition.call(
      dataset: create(:full_dataset, num_docs: 10),
      split_across: false,
      num_words: 10)

    assert_equal 10, analyzer.word_list.size
    analyzer.blocks.each do |b|
      assert_empty b.keys - analyzer.word_list
    end
  end
end
