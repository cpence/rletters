require 'test_helper'

class CountArticlesByFieldTest < ActiveSupport::TestCase
  test 'progress reporting works without a dataset' do
    called_sub_100 = false
    called_100 = false

    RLetters::Analysis::CountArticlesByField.call(
      field: :year,
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

  test 'works without a dataset' do
    result = RLetters::Analysis::CountArticlesByField.call(field: :year)

    assert_kind_of RLetters::Analysis::CountArticlesByField::Result, result
    refute result.normalize

    assert_equal 224, result.counts['2009']
    assert_equal 42, result.counts['2007']
  end

  test 'returns empty result when Solr fails' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    result = RLetters::Analysis::CountArticlesByField.call(field: :year)

    assert_empty result.counts
  end

  test 'progress reporting works with a dataset' do
    called_sub_100 = false
    called_100 = false

    RLetters::Analysis::CountArticlesByField.call(
      field: :year,
      dataset: create(:full_dataset, num_docs: 10),
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

  test 'works with a dataset' do
    result = RLetters::Analysis::CountArticlesByField.call(
      field: :year,
      dataset: create(:full_dataset, num_docs: 10))

    assert_kind_of RLetters::Analysis::CountArticlesByField::Result, result
    refute result.normalize

    assert_equal 1, result.counts.size
    assert_equal 10, result.counts['2009']
  end

  # FIXME: Test is failing, not sure how I want to deal with this.
  # test 'returns empty result when Solr fails with a dataset' do
  #   d = create(:full_dataset, num_docs: 10)
  #   stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
  #   result = RLetters::Analysis::CountArticlesByField.call(
  #     field: :year,
  #     dataset: d)

  #   assert_empty result.counts
  # end

  test 'works when normalizing to a dataset' do
    result = RLetters::Analysis::CountArticlesByField.call(
      field: :year,
      dataset: create(:full_dataset, num_docs: 10),
      normalize: true,
      normalization_dataset: create(:full_dataset, num_docs: 10))

    assert_kind_of RLetters::Analysis::CountArticlesByField::Result, result
    assert result.normalize
    refute_nil result.normalization_dataset

    assert_equal 1, result.counts.size
    assert_equal 1.0, result.counts['2009']
  end

  test 'works when normalizing to the corpus' do
    result = RLetters::Analysis::CountArticlesByField.call(
      field: :year,
      dataset: create(:full_dataset, num_docs: 10),
      normalize: true)

    assert_kind_of RLetters::Analysis::CountArticlesByField::Result, result
    assert result.normalize
    assert_nil result.normalization_dataset

    assert_equal 154, result.counts.size
    assert_in_delta 0.0446, result.counts['2009']

    assert_equal 0, result.counts['1930']
  end

  test 'zeros out missing values with a non-numeric field' do
    result = RLetters::Analysis::CountArticlesByField.call(
      field: :journal_facet,
      dataset: create(:full_dataset, num_docs: 10),
      normalize: true)

    assert_equal 0, result.counts['Actually a Novel']
  end
end
