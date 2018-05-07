# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Documents
    class WordListTest < ActiveSupport::TestCase
      setup do
        # Just always return the same document stub
        @doc = build(:full_document)
        Document.stubs(:find_by!).returns(@doc)
      end

      test 'with 1-grams' do
        lister = RLetters::Documents::WordList.new
        list = lister.words_for(@doc.uid)

        assert_equal %w[it was the best of], list.take(5)
        assert_equal 1486, lister.corpus_dfs['it']
      end

      test 'with 2-grams' do
        lister = RLetters::Documents::WordList.new(ngrams: 2)
        list = lister.words_for(@doc.uid)

        assert_equal 'it was', list.first
        assert_equal 'was the', list.second

        list.each do |g|
          assert_equal 2, g.split.size
        end
      end

      test 'with stemming' do
        lister = RLetters::Documents::WordList.new(stemming: :stem)
        list = lister.words_for(@doc.uid)

        assert_includes list, 'wa'
        refute_includes list, 'was'

        refute_nil lister.corpus_dfs['wa']
      end

      test 'with lemmatization' do
        old_path = ENV['NLP_TOOL_PATH']
        ENV['NLP_TOOL_PATH'] = 'stubbed'

        lister = RLetters::Documents::WordList.new(stemming: :lemma)
        words = build(:lemmatizer).words
        RLetters::Analysis::NLP.expects(:lemmatize_words)
                               .at_least_once.returns(words)
        list = lister.words_for(@doc.uid)

        assert_equal %w[it be the], list.take(3)
        refute_includes list, 'was'

        ENV['NLP_TOOL_PATH'] = old_path
      end
    end
  end
end
