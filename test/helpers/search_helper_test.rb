# frozen_string_literal: true

require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  # There's no reason that we should have to do this, but for some reason Rails
  # isn't including the other helpers into the context when we test this helper.
  # Try removing this in future Rails versions to see if it gets fixed.
  include ApplicationHelper

  test 'facet_addition_links should have link for adding author facet' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index')
    controller.stubs(:params).returns(h)

    res = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
    ret = facet_addition_links(res.facets, :authors_facet)

    url = '/search?' + CGI.escape('fq[]=authors_facet:"Peter J. Hotez"').gsub('%26', '&').gsub('%3D', '=')
    assert_includes ret, url
  end

  test 'facet_addition_links should have link for adding journal facet' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index')
    controller.stubs(:params).returns(h)

    res = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
    ret = facet_addition_links(res.facets, :journal_facet)

    url = '/search?' + CGI.escape('fq[]=journal_facet:"PLoS Neglected Tropical Diseases"').gsub('%26', '&').gsub('%3D', '=')
    assert_includes ret, url
  end

  test 'facet_addition_links should have link for adding year facet' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index')
    controller.stubs(:params).returns(h)

    res = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
    ret = facet_addition_links(res.facets, :year)

    url = '/search?' + CGI.escape('fq[]=year:[2000 TO 2009]').gsub('%26', '&').gsub('%3D', '=')
    assert_includes ret, url
  end

  # rletters/rletters#98
  test 'facet_removal_links works with nil facets' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         q: '*:*', defType: 'lucene').permit!
    controller.stubs(:params).returns(h)

    assert_empty facet_removal_links(nil)
  end

  test 'facet_removal_links works with nothing active' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         q: '*:*', defType: 'lucene').permit!
    controller.stubs(:params).returns(h)

    res = RLetters::Solr::Connection.search(params.to_h)

    assert_empty facet_removal_links(res.facets)
  end

  test 'facet_removal_links works with an active facet' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']).permit!
    controller.stubs(:params).returns(h)

    res = RLetters::Solr::Connection.search(params.to_h)
    ret = facet_removal_links(res.facets)

    assert_includes ret, 'href="/search"'
    assert_includes ret, 'Journal: PLoS Neglected Tropical Diseases'
  end

  test 'facet_removal_links works with overlapping facet and category' do
    cat = create(:category)
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         categories: [cat.to_param],
                                         fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']).permit!
    controller.stubs(:params).returns(h)

    res = RLetters::Solr::Connection.search(params.to_h)
    ret = facet_removal_links(res.facets)

    assert_includes ret, "href=\"/search?categories%5B%5D=#{cat.to_param}\""
    assert_includes ret, 'Journal: PLoS Neglected Tropical Diseases'
  end

  test 'category_addition_tree works' do
    parent = create(:category, name: 'Parent')
    create(:category, name: 'Child', parent: parent)
    Documents::Category.stubs(:roots).returns([parent])

    h = ActionController::Parameters.new(controller: 'search', action: 'index').permit!
    controller.stubs(:params).returns(h)

    tree = category_addition_tree

    assert_includes tree, 'Parent</a><ul>'
    assert_includes tree, 'Child</a></li></ul>'
  end

  test 'category_removal_links works with nothing active' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         q: '*:*', defType: 'lucene').permit!
    controller.stubs(:params).returns(h)

    assert_empty category_removal_links
  end

  test 'category_removal_links works with a category active' do
    cat = create(:category)
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         categories: [cat.to_param]).permit!
    controller.stubs(:params).returns(h)

    ret = category_removal_links

    assert_includes ret, 'href="/search"'
    assert_includes ret, 'Category: Test Category'
  end

  test 'category_removal_links works with overlapping facet and category' do
    cat = create(:category)
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         categories: [cat.to_param],
                                         fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']).permit!
    controller.stubs(:params).returns(h)

    ret = category_removal_links

    assert_includes ret, 'href="/search?fq%5B%5D=journal_facet%3A%22PLoS+Neglected+Tropical+Diseases%22"'
    assert_includes ret, 'Category: Test Category'
  end
end
