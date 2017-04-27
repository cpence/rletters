require 'test_helper'

class AdminHelperTest < ActionView::TestCase
  test 'as_nestable_list' do
    parent = create(:category, name: 'Parent')
    child = create(:category, name: 'Child')
    parent.children << child

    ret = as_nestable_list([parent]) do |i|
      i.to_s
    end

    assert_dom_equal %Q{<div class="dd"><ol class="dd-list"><li class="dd-item" data-id="#{parent.to_param}">Parent<ol class="dd-list"><li class="dd-item" data-id="#{child.to_param}">Child</li></ol></li></ol></div>}, ret
  end

  class AdminValueTester
    attr_accessor :regular, :array

    def self.admin_attributes
      {
        regular: {},
        array: { array: true }
      }
    end
  end

  test 'admin_value_for with nil attribute' do
    obj = AdminValueTester.new
    obj.regular = nil

    assert_equal '<nil>', admin_value_for(obj, :regular)
  end

  test 'admin_value_for with empty array' do
    obj = AdminValueTester.new
    obj.array = []

    assert_equal '<empty>', admin_value_for(obj, :array)
  end

  test 'admin_value_for with full array' do
    obj = AdminValueTester.new
    obj.array = [1, 2, 3]

    assert_dom_equal %q{<ul><li>1</li><li>2</li><li>3</li></ul>}, admin_value_for(obj, :array)
  end

  test 'admin_value_for with model associations' do
    dataset = create(:dataset)

    assert_dom_equal %Q{<a href='#{admin_item_path(model: 'user', id: dataset.user.to_param)}'>#{CGI::escapeHTML(dataset.user.to_s)}</a>}, admin_value_for(dataset, :user)
  end
end
