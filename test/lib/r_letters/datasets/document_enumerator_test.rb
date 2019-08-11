# frozen_string_literal: true

require 'test_helper'

module RLetters
  module Datasets
    class DocumentEnumeratorTest < ActiveSupport::TestCase
      test 'with no custom fields, enumerates documents' do
        enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2))

        assert_includes WORKING_UIDS, enum.first.uid
      end

      test 'with no custom fields, includes no term vectors' do
        enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2))

        assert_nil enum.first.term_vectors
      end

      test 'with no custom fields, throws if Solr fails' do
        enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2))
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout

        assert_raises(RLetters::Solr::Connection::Error) do
          enum.each { |_| }
        end
      end

      test 'with term vectors, it returns term vectors' do
        enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2),
                                                          term_vectors: true)

        refute_nil enum.first.term_vectors
      end

      test 'with custom fields, it only includes those' do
        enum = RLetters::Datasets::DocumentEnumerator.new(dataset: create(:full_dataset, num_docs: 2),
                                                          fl: 'year')

        assert_nil enum.first.title
        refute_nil enum.first.year
      end
    end
  end
end
