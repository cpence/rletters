require 'rails_helper'

RSpec.describe AdminControllerHelper, type: :helper do
  describe '#admin_value_for' do
    it 'needs some specs'
  end

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
end
