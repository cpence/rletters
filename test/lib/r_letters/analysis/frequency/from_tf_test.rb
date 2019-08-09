# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Analysis
    module Frequency
      class FromTfTest < ActiveSupport::TestCase
        test 'with one block, includes all words' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10))

          assert_equal analyzer.blocks[0].size, analyzer.block_stats[0][:types]
        end

        test 'with one block, builds correct blocks' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10))

          assert_kind_of Array, analyzer.blocks
          assert_kind_of Hash, analyzer.blocks[0]
          assert_kind_of String, analyzer.blocks[0].first[0]
          assert_kind_of Integer, analyzer.blocks[0].first[1]

          refute_nil analyzer.num_dataset_types
          refute_nil analyzer.num_dataset_tokens
        end

        test 'with one block, puts the same words in all blocks' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10))

          analyzer.blocks.each do |b|
            assert_equal b.keys, (b.keys & analyzer.word_list)
          end
        end

        test 'with one block, gives same stats as dataset' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10))

          assert_equal analyzer.num_dataset_types, analyzer.blocks[0].size

          refute_nil analyzer.block_stats[0][:name]
          assert_equal analyzer.num_dataset_types, analyzer.block_stats[0][:types]
          assert_equal analyzer.num_dataset_tokens, analyzer.block_stats[0][:tokens]
        end

        test 'with one block, gives correct tf_in_dataset' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10))

          analyzer.word_list.each do |w|
            assert_equal analyzer.blocks[0][w], analyzer.tf_in_dataset[w]
          end
        end

        test 'with one block, df_in_dataset works' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10))

          analyzer.word_list.each do |w|
            refute_nil analyzer.df_in_dataset[w]
          end

          assert_equal 1, analyzer.df_in_dataset['malaria']
          assert_equal 8, analyzer.df_in_dataset['disease']
        end

        test 'with one block, df_in_corpus works' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10))

          analyzer.word_list.each do |w|
            refute_nil analyzer.df_in_corpus[w]
          end

          assert_equal 128, analyzer.df_in_corpus['malaria']
          assert_equal 1104, analyzer.df_in_corpus['disease']
        end

        test 'with one block per document, builds correct blocks' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                split_across: false)

          assert_kind_of Array, analyzer.blocks
          assert_kind_of Hash, analyzer.blocks[0]
          assert_kind_of String, analyzer.blocks[0].first[0]
          assert_kind_of Integer, analyzer.blocks[0].first[1]

          refute_nil analyzer.num_dataset_types
          refute_nil analyzer.num_dataset_tokens
        end

        test 'with one block per document, gives correct number of blocks' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                split_across: false)

          assert_equal 10, analyzer.blocks.size
        end

        test 'with one block per document, includes all words' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                split_across: false)

          refute_nil analyzer.block_stats[0][:name]
          assert_equal analyzer.block_stats[0][:types], analyzer.blocks[0].size
          refute_nil analyzer.block_stats[0][:tokens]
        end

        test 'with one block per document, tf_in_dataset works' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                split_across: false)

          analyzer.word_list.each do |w|
            refute_nil analyzer.tf_in_dataset[w]
          end
        end

        test 'with one block per document, df_in_dataset works' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                split_across: false)

          analyzer.word_list.each do |w|
            refute_nil analyzer.df_in_dataset[w]
          end

          assert_equal 1, analyzer.df_in_dataset['malaria']
          assert_equal 8, analyzer.df_in_dataset['disease']
        end

        test 'with one block per document, df_in_corpus works' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                split_across: false)

          analyzer.word_list.each do |w|
            refute_nil analyzer.df_in_corpus[w]
          end

          assert_equal 128, analyzer.df_in_corpus['malaria']
          assert_equal 1104, analyzer.df_in_corpus['disease']
        end

        test 'raises if num_words is negative' do
          assert_raises(ArgumentError) do
            RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset),
                                                       num_words: -1)
          end
        end

        test 'num_words limits number of words returned' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                num_words: 10)

          analyzer.blocks.each do |b|
            assert_equal 10, b.size
          end
        end

        test 'num_words is ignored when all is set' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                num_words: 10,
                                                                all: true)

          assert_equal analyzer.num_dataset_types, analyzer.block_stats[0][:types]
        end

        test 'inclusion_list works' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                inclusion_list: 'malaria disease')

          assert_equal %w[disease malaria], analyzer.blocks[0].keys.sort
        end

        test 'exclusion_list works' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                exclusion_list: 'a the')

          refute_includes analyzer.blocks[0].keys, 'a'
          refute_includes analyzer.blocks[0].keys, 'the'

          refute_empty analyzer.blocks[0].keys
        end

        test 'stop_list works' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                stop_list: %w[a an the])

          refute_includes analyzer.blocks[0].keys, 'a'
          refute_includes analyzer.blocks[0].keys, 'the'

          refute_empty analyzer.blocks[0].keys
        end

        test 'word_list only includes the requested list of words' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                num_words: 10)

          assert_equal 10, analyzer.word_list.size
        end

        test 'word_list gives analyzed words' do
          analyzer = RLetters::Analysis::Frequency::FromTf.call(dataset: create(:full_dataset,
                                                                                num_docs: 10),
                                                                num_words: 10)

          analyzer.word_list.each do |w|
            refute_nil analyzer.blocks[0][w]
          end
        end

        test 'progress reporting works' do
          called_sub100 = false
          called100 = false

          RLetters::Analysis::Frequency::FromTf.call(
            dataset: create(:full_dataset, num_docs: 10),
            progress: lambda do |p|
              if p < 100
                called_sub100 = true
              else
                called100 = true
              end
            end
          )

          assert called_sub100
          assert called100
        end
      end
    end
  end
end
