require 'rails_helper'

RSpec.describe AdminControllerHelper, type: :helper do
  describe '#as_nestable_list' do
    before(:example) do
      @parent = create(:category, name: 'Parent')
      @child = create(:category, name: 'Child')
      @parent.children << @child

      @ret = helper.as_nestable_list([@parent]) do |i|
        i.to_s
      end
    end

    it 'returns a div class' do
      expect(@ret).to have_selector('div.dd')
    end

    it 'puts an ordered list just under the div' do
      expect(@ret).to have_selector('div.dd ol.dd-list')
    end

    it 'outputs an item for the parent' do
      expect(@ret).to have_selector('div.dd ol.dd-list li.dd-item',
                                    text: 'Parent')
    end

    it 'outputs a nested list for the child' do
      expect(@ret).to have_selector('div.dd ol.dd-list li.dd-item ' +
                                    'ol.dd-list li.dd-item',
                                    text: 'Child')
    end
  end

  describe '#admin_value_for' do
    class AdminValueTester
      attr_accessor :regular, :array

      def self.admin_attributes
        {
          regular: {},
          array: { array: true }
        }
      end
    end

    it 'works for nil values' do
      obj = AdminValueTester.new
      obj.regular = nil

      expect(helper.admin_value_for(obj, :regular)).to eq('<nil>')
    end

    it 'works for empty arrays' do
      obj = AdminValueTester.new
      obj.array = []

      expect(helper.admin_value_for(obj, :array)).to eq('<empty>')
    end

    it 'works for full arrays' do
      obj = AdminValueTester.new
      obj.array = [1, 2, 3]

      ret = helper.admin_value_for(obj, :array)
      expect(ret).to have_selector('ul li', text: '1')
      expect(ret).to have_selector('ul li', text: '2')
      expect(ret).to have_selector('ul li', text: '3')
    end

    it 'works for model associations' do
      # This we have to do by testing one of our proper ActiveRecord models
      user = create(:user)
      dataset = create(:dataset, user: user)

      ret = helper.admin_value_for(dataset, :user)
      expect(ret).to have_selector("a[href='#{helper.admin_item_path(model: "user", id: user.to_param)}']",
                                   text: user.to_s)
    end
  end
end
