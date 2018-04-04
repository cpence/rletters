require 'test_helper'

class RLetters::Presenters::FacetPresenterTest < ActiveSupport::TestCase
  test 'label reproduces authors' do
    f = RLetters::Solr::Facet.new(field: 'authors_facet',
                                  value: '"W. Shatner"', hits: 10)
    pres = RLetters::Presenters::FacetPresenter.new(facet: f)

    assert_equal 'W. Shatner', pres.label
  end

  test 'label reproduces journals' do
    f = RLetters::Solr::Facet.new(field: 'journal_facet',
                                  value: '"The Journal"', hits: 10)
    pres = RLetters::Presenters::FacetPresenter.new(facet: f)

    assert_equal 'The Journal', pres.label
  end

  test 'label creates proper decade labels' do
    f = RLetters::Solr::Facet.new(query: 'year:[1960 TO 1969]', hits: 10)
    pres = RLetters::Presenters::FacetPresenter.new(facet: f)

    assert_equal '1960–1969', pres.label
  end

  test 'label creates the before-year label correctly' do
    f = RLetters::Solr::Facet.new(query: 'year:[* TO 1800]', hits: 10)
    pres = RLetters::Presenters::FacetPresenter.new(facet: f)

    assert_equal 'Before 1800', pres.label
  end

  test 'label creates the after-year label correctly' do
    f = RLetters::Solr::Facet.new(query: 'year:[2010 TO *]', hits: 10)
    pres = RLetters::Presenters::FacetPresenter.new(facet: f)

    assert_equal '2010 and later', pres.label
  end

  test 'label throws for invalid fields' do
    f = stub(field: :space_facet, value: 'Spaceman Spiff', hits: 10,
             to_hash: { field: :space_facet, value: 'Spaceman Spiff',
                        hits: 10 })

    assert_raises(ArgumentError) do
      RLetters::Presenters::FacetPresenter.new(facet: f).label
    end
  end

  test 'field_label has label for author' do
    f = RLetters::Solr::Facet.new(field: 'authors_facet',
                                  value: '"W. Shatner"', hits: 10)
    pres = RLetters::Presenters::FacetPresenter.new(facet: f)

    assert_equal 'Authors', pres.field_label
  end

  test 'field_label has label for journal' do
    f = RLetters::Solr::Facet.new(field: 'journal_facet',
                                  value: '"The Journal"', hits: 10)
    pres = RLetters::Presenters::FacetPresenter.new(facet: f)

    assert_equal 'Journal', pres.field_label
  end

  test 'field_label has label for year' do
    f = RLetters::Solr::Facet.new(query: 'year:[1960 TO 1969]', hits: 10)
    pres = RLetters::Presenters::FacetPresenter.new(facet: f)

    assert_equal 'Year', pres.field_label
  end

  test 'field_label throws for invalid fields' do
    f = stub(field: :space_facet, value: 'Spaceman Spiff', hits: 10,
             to_hash: { field: :space_facet, value: 'Spaceman Spiff',
                        hits: 10 })

    assert_raises(ArgumentError) do
      RLetters::Presenters::FacetPresenter.new(facet: f).field_label
    end
  end
end
