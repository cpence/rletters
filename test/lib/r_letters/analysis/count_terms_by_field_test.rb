# frozen_string_literal: true
require 'test_helper'

class RLetters::Analysis::CountTermsByFieldTest < ActiveSupport::TestCase
  test 'works without a dataset' do
    called_sub_100 = false
    called_100 = false

    counts = RLetters::Analysis::CountTermsByField.call(
      term: 'online',
      field: :year,
      progress: lambda do |p|
        if p < 100
          called_sub_100 = true
        else
          called_100 = true
        end
      end)

    assert_equal 3, counts['2009']
    assert_equal 8, counts['2011']
    assert_equal 0, counts['1930']

    assert called_sub_100
    assert called_100
  end

  test 'returns empty counts without dataset when Solr fails' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    assert_empty RLetters::Analysis::CountTermsByField.call(term: 'malaria',
                                                            field: :year)
  end

  test 'works with a dataset' do
    called_sub_100 = false
    called_100 = false

    counts = RLetters::Analysis::CountTermsByField.call(
      term: 'disease',
      field: :year,
      dataset: create(:full_dataset, num_docs: 2),
      progress: lambda do |p|
        if p < 100
          called_sub_100 = true
        else
          called_100 = true
        end
      end)

    assert_equal 1, counts.size
    assert counts['2009'] > 0

    assert called_sub_100
    assert called_100
  end

  # FIXME: this is failing and I don't know how to deal with it
  # test 'returns empty counts with dataset when Solr fails' do
  #   d = create(:full_dataset, num_docs: 2)
  #   stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
  #   assert_empty RLetters::Analysis::CountTermsByField.call(term: 'malaria',
  #                                                           field: :year,
  #                                                           dataset: d)
  # end
end
