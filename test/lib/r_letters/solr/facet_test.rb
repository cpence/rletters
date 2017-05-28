require 'test_helper'

class FacetTest < ActiveSupport::TestCase
  test 'initialize with query but no hits raises' do
    assert_raises(Virtus::CoercionError) do
      RLetters::Solr::Facet.new(query: 'year:[1960 TO 1969]')
    end
  end

  test 'initialize with malformed query raises' do
    assert_raises(ArgumentError) do
      RLetters::Solr::Facet.new(query: 'asdf', hits: 10)
    end
  end

  test 'initialize with query for unexpected field raises' do
    assert_raises(ArgumentError) do
      RLetters::Solr::Facet.new(query: 'authors_facet:"W. Shatner"', hits: 10)
    end
  end

  test 'initialize works for well formed query' do
    f = RLetters::Solr::Facet.new(query: 'year:[1960 TO 1969]', hits: 10)
    assert_equal 'year:[1960 TO 1969]', f.query
  end

  test 'initialize with value but no field raises' do
    assert_raises(ArgumentError) do
      RLetters::Solr::Facet.new(value: 'W. Shatner', hits: 10)
    end
  end

  test 'initialize with field but no value raises' do
    assert_raises(ArgumentError) do
      RLetters::Solr::Facet.new(field: 'authors_facet', hits: 10)
    end
  end

  test 'initialize with field and value but no hits raises' do
    assert_raises(Virtus::CoercionError) do
      RLetters::Solr::Facet.new(field: 'authors_facet', value: 'W. Shatner')
    end
  end

  test 'initialize with unknown field raises' do
    assert_raises(ArgumentError) do
      RLetters::Solr::Facet.new(field: 'zuzax', value: 'W. Shatner', hits: 10)
    end
  end

  test 'initialize strips quotes with standard three-parameter form' do
    f = RLetters::Solr::Facet.new(field: 'authors_facet',
                                  value: '"W. Shatner"',
                                  hits: 10)

    assert_equal 'W. Shatner', f.value
  end

  test 'initialize builds queries for standard three-parameter form' do
    f = RLetters::Solr::Facet.new(field: 'authors_facet',
                                  value: '"W. Shatner"',
                                  hits: 10)

    assert_equal 'authors_facet:"W. Shatner"', f.query
  end

  test 'sort operator works for facets with different hits' do
    f1 = RLetters::Solr::Facet.new(field: 'authors_facet', value: '"W. Shatner"', hits: 10)
    f2 = RLetters::Solr::Facet.new(field: 'authors_facet', value: '"P. Stewart"', hits: 20)

    assert f2 < f1
  end

  test 'sort operator sorts alphabetically for same hits on authors' do
    f1 = RLetters::Solr::Facet.new(field: 'authors_facet', value: '"W. Shatner"', hits: 10)
    f2 = RLetters::Solr::Facet.new(field: 'authors_facet', value: '"P. Stewart"', hits: 10)

    assert f1 > f2
  end

  test 'sort operator sorts years inverse for same hits on years' do
    f1 = RLetters::Solr::Facet.new(query: 'year:[1850 TO 1860]', hits: 10)
    f2 = RLetters::Solr::Facet.new(query: 'year:[1950 TO 1960]', hits: 10)

    assert f2 < f1
  end
end
