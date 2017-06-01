require 'test_helper'

class SearchHelperTest < ActionView::TestCase
  test 'document_citation renders default when not logged in' do
    doc = Document.find(generate(:working_uid))
    flexmock(self, current_user: nil, user_signed_in?: false)
      .should_receive(:render)
      .with(partial: 'document', locals: { document: doc })
    document_citation(doc)
  end

  test 'document_citation renders default when no CSL style set' do
    doc = Document.find(generate(:working_uid))
    flexmock(self, current_user: create(:user), user_signed_in?: true)
      .should_receive(:render)
      .with(partial: 'document', locals: { document: doc })
    document_citation(doc)
  end

  test 'document_citation renders CSL style for local document' do
    doc = Document.find(generate(:working_uid))
    csl_style = create(:csl_style)
    flexmock(self, current_user: create(:user, csl_style_id: csl_style.id),
             user_signed_in?: true)
    flexmock(RLetters::Documents::AsCSL).new_instances.should_receive(:entry)
      .with(csl_style).and_return('')

    document_citation(doc)
  end

  test 'document_citation renders cloud icon for remote document' do
    doc = Document.find('gutenberg:3172')
    csl_style = create(:csl_style)
    flexmock(self, current_user: create(:user, csl_style_id: csl_style.id),
             user_signed_in?: true)
    flexmock(RLetters::Documents::AsCSL).new_instances
      .should_receive(:entry).with(csl_style).and_return('')

    ret = document_citation(doc)
    assert_includes ret, 'fi-upload-cloud'
  end

  test 'facet_addition_links should have link for adding author facet' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index')
    flexmock(controller, params: h)

    res = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
    ret = facet_addition_links(res.facets, :authors_facet)

    url = '/search?' + CGI.escape('fq[]=authors_facet:"Peter J. Hotez"').gsub('%26', '&').gsub('%3D', '=')
    assert_includes ret, url
  end

  test 'facet_addition_links should have link for adding journal facet' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index')
    flexmock(controller, params: h)

    res = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
    ret = facet_addition_links(res.facets, :journal_facet)

    url = '/search?' + CGI.escape('fq[]=journal_facet:"PLoS Neglected Tropical Diseases"').gsub('%26', '&').gsub('%3D', '=')
    assert_includes ret, url
  end

  test 'facet_addition_links should have link for adding year facet' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index')
    flexmock(controller, params: h)

    res = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
    ret = facet_addition_links(res.facets, :year)

    url = '/search?' + CGI.escape('fq[]=year:[2000 TO 2009]').gsub('%26', '&').gsub('%3D', '=')
    assert_includes ret, url
  end

  test 'facet_removal_links works with nothing active' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         q: '*:*', defType: 'lucene').permit!
    flexmock(controller, params: h)

    res = RLetters::Solr::Connection.search(params.to_h)

    assert_empty facet_removal_links(res.facets)
  end

  test 'facet_removal_links works with an active facet' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']).permit!
    flexmock(controller, params: h)

    res = RLetters::Solr::Connection.search(params.to_h)
    ret = facet_removal_links(res.facets)

    assert_includes ret, 'href="/search"'
    assert_includes ret, 'Journal: PLoS Neglected Tropical Diseases'
  end

  test 'facet_removal_links works with overlapping facet and category' do
    cat = create(:category)
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         categories: [@category.to_param],
                                         fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']).permit!
    flexmock(controller, params: h)

    res = RLetters::Solr::Connection.search(params.to_h)
    ret = facet_removal_links(res.facets)

    assert_includes ret, "href=\"/search?categories%5B%5D=#{@category.to_param}\""
    assert_includes ret, 'Journal: PLoS Neglected Tropical Diseases'
  end

  test 'category_addition_tree works' do
    parent = create(:category, name: 'Parent')
    child = create(:category, name: 'Child')
    parent.children << child
    flexmock(Documents::Category, roots: [parent])

    h = ActionController::Parameters.new(controller: 'search', action: 'index').permit!
    flexmock(controller, params: h)

    tree = category_addition_tree

    assert_includes tree, "Parent\n</a><ul>"
    assert_includes tree, "Child\n</a></li></ul>"
  end

  test 'category_removal_links works with nothing active' do
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         q: '*:*', defType: 'lucene').permit!
    flexmock(controller, params: h)

    assert_empty category_removal_links
  end

  test 'category_removal_links works with a category active' do
    cat = create(:category)
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         categories: [cat.to_param]).permit!
    flexmock(controller, params: h)

    ret = category_removal_links

    assert_includes ret, 'href="/search"'
    assert_includes ret, 'Category: Test Category'
  end

  test 'category_removal_links works with overlapping facet and category' do
    cat = create(:category)
    h = ActionController::Parameters.new(controller: 'search', action: 'index',
                                         categories: [cat.to_param],
                                         fq: ['journal_facet:"PLoS Neglected Tropical Diseases"']).permit!
    flexmock(controller, params: h)

    ret = category_removal_links

    assert_includes ret, 'href="/search?fq%5B%5D=journal_facet%3A%22PLoS+Neglected+Tropical+Diseases%22"'
    assert_includes ret, 'Category: Test Category'
  end
end
