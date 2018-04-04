require 'test_helper'

class RLetters::Presenters::QueryPresenterTest < ActiveSupport::TestCase
  test 'def_type_string works for regular search' do
    q = Datasets::Query.new(q: 'testing', def_type: 'dismax')
    pres = RLetters::Presenters::QueryPresenter.new(query: q)

    assert_equal 'Normal search', pres.def_type_string
  end

  test 'def_type_string works for advanced search' do
    q = Datasets::Query.new(q: 'testing', fq: ['year:[1960 TO 1969]'],
                            def_type: 'lucene')
    pres = RLetters::Presenters::QueryPresenter.new(query: q)

    assert_equal 'Advanced search', pres.def_type_string
  end

  test 'fq_string uses facet decorators' do
    q = Datasets::Query.new(q: 'testing', fq: ['year:[1960 TO 1969]'],
                            def_type: 'lucene')
    pres = RLetters::Presenters::QueryPresenter.new(query: q)

    assert_equal 'Year: 1960–1969', pres.fq_string[0]
  end

  test 'fq_string throws for a bad facet' do
    q = Datasets::Query.new(q: 'testing', fq: ['purple'])
    pres = RLetters::Presenters::QueryPresenter.new(query: q)

    assert_raises(ArgumentError) do
      pres.fq_string
    end
  end

  test 'fq_string returns nil if no facets' do
    q = Datasets::Query.new(q: 'testing', def_type: 'dismax')
    pres = RLetters::Presenters::QueryPresenter.new(query: q)

    assert_nil pres.fq_string
  end
end
