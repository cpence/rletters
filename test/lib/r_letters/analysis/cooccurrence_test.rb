# frozen_string_literal: true

require 'test_helper'
require 'r_letters/analysis/nlp'

module RLetters
  module Analysis
    class CooccurrenceTest < ActiveSupport::TestCase
      test 'raises an error for invalid scoring method' do
        assert_raises(ArgumentError) do
          RLetters::Analysis::Cooccurrence.call(scoring: :nope, dataset: create(:dataset))
        end
      end

      %i[log_likelihood mutual_information t_test].each do |scoring|
        test "single word analysis with #{scoring} works" do
          called_sub100 = false
          called100 = false

          result = RLetters::Analysis::Cooccurrence.call(
            scoring: scoring,
            dataset: create(:full_dataset, num_docs: 2),
            num_pairs: 10,
            words: 'abstract',
            window: 50,
            progress: lambda do |p|
              if p < 100
                called_sub100 = true
              else
                called100 = true
              end
            end
          )

          assert_kind_of RLetters::Analysis::Cooccurrence::Result, result
          assert_equal scoring, result.scoring

          grams = result.cooccurrences
          assert_equal 10, grams.size

          grams.each do |g|
            assert_kind_of Numeric, g[1]
            assert g[1].positive? if g[1].is_a?(Integer)
            assert g[1].finite? if g[1].is_a?(Float)
          end

          assert called_sub100
          assert called100
        end

        test "multiple word analysis with #{scoring} works" do
          result = RLetters::Analysis::Cooccurrence.call(
            scoring: scoring,
            dataset: create(:full_dataset, num_docs: 2),
            num_pairs: 10,
            words: 'abstract background',
            window: 50
          )

          assert_kind_of RLetters::Analysis::Cooccurrence::Result, result
          assert_equal scoring, result.scoring

          grams = result.cooccurrences
          assert_equal 1, grams.size

          grams.each do |g|
            assert_kind_of Numeric, g[1]
            assert g[1].positive? if g[1].is_a?(Integer)
            assert g[1].finite? if g[1].is_a?(Float)
          end
        end

        test "stemmed analysis with #{scoring} works" do
          result = RLetters::Analysis::Cooccurrence.call(
            scoring: scoring,
            dataset: create(:full_dataset, num_docs: 2),
            words: 'abstract',
            window: 50,
            stemming: :stem
          )

          assert_kind_of RLetters::Analysis::Cooccurrence::Result, result
          assert_equal scoring, result.scoring
          assert_equal :stem, result.stemming

          g = result.cooccurrences.find { |gram| gram.first == 'abstract ar' }
          refute_nil g
        end

        test "lemmatized analysis with #{scoring} works" do
          old_path = ENV['NLP_TOOL_PATH']
          ENV['NLP_TOOL_PATH'] = 'stubbed'

          # This is annoying, but it's the simplest way to monkey-patch in a fake
          # version of NLP so that we can be sure it's actually being called.
          RLetters::Analysis::NLP.define_singleton_method :fake_lemmatize_words do |array|
            array == ['abstract'] ? ['the'] : array
          end
          RLetters::Analysis::NLP.singleton_class.send(:alias_method, :real_lemmatize_words, :lemmatize_words)
          RLetters::Analysis::NLP.singleton_class.send(:alias_method, :lemmatize_words, :fake_lemmatize_words)

          result = RLetters::Analysis::Cooccurrence.call(
            scoring: scoring,
            dataset: create(:full_dataset, num_docs: 2),
            num_pairs: 10,
            words: 'abstract',
            window: 50,
            stemming: :lemma
          )

          RLetters::Analysis::NLP.singleton_class.send(:alias_method, :lemmatize_words, :real_lemmatize_words)

          assert_kind_of RLetters::Analysis::Cooccurrence::Result, result
          assert_equal scoring, result.scoring
          assert_equal :lemma, result.stemming

          result.cooccurrences.each do |g|
            assert g.first.start_with?('the ')
          end

          ENV['NLP_TOOL_PATH'] = old_path
        end

        # Regression test for a bug
        test "analysis with an uppercased word works with #{scoring}" do
          result = RLetters::Analysis::Cooccurrence.call(
            scoring: scoring,
            dataset: create(:full_dataset, num_docs: 2),
            num_pairs: 10,
            words: 'ABSTRACT',
            window: 50
          )

          assert_includes result.cooccurrences[0][0].split, 'abstract'
        end
      end
    end
  end
end
