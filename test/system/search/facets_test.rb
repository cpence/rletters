# frozen_string_literal: true

require 'application_system_test_case'

class FacetsTest < ApplicationSystemTestCase
  test 'browse by journal' do
    visit search_path

    within('.filter-list') do
      click_link 'PLoS Neglected Tropical Diseases'
    end

    assert_text(/1500 articles /i)
    assert_selector 'a.nav-link', text: 'PLoS Neglected Tropical Diseases'
  end

  test 'clear a single facet' do
    visit search_path

    within('.filter-list') do
      click_link 'PLoS Neglected Tropical Diseases'
      click_link 'Peter J. Hotez'
    end

    within('#filters') do
      click_link 'Authors: Peter J. Hotez'
    end

    assert_text(/1500 articles /i)
    assert_selector 'a.nav-link', text: 'PLoS Neglected Tropical Diseases'
  end

  test 'clear all facets' do
    visit search_path

    within('.filter-list') do
      click_link 'PLoS Neglected Tropical Diseases'
    end
    within('#filters') do
      click_link('Remove All')
    end

    assert_text(/1501 articles /i)
    assert_no_selector '.filter-header', text: 'Active filters'
  end
end
