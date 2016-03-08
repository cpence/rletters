require 'rails_helper'

RSpec.describe Documents::CategoriesDecorator, type: :decorator do
  include Capybara::RSpecMatchers

  describe '#removal_links' do
    before(:example) do
      @category = build_stubbed(:category)
      @ret = described_class.decorate([@category]).removal_links
    end

    it 'includes a link to remove the category' do
      expect(@ret).to have_selector("a[href=\"/search\"]", text: "Category: #{@category.name}")
    end
  end

  describe '#link_tree' do
    before(:example) do
      @parent = create(:category, name: 'Parent')
      @child = create(:category, name: 'Child')
      @parent.children << @child
      allow(Documents::Category).to receive(:roots).and_return(@parent)

      @ret = described_class.decorate([@parent, @child]).link_tree
    end

    it 'returns a proper tree' do
      expect(@ret).to have_selector('li', text: 'Parent')
      expect(@ret).to have_selector('li ul li', text: 'Child')
    end
  end

  # Tests for the shared behavior in TreeDecoration
  describe '#as_nestable_list' do
    before(:example) do
      Draper::ViewContext.current.class_eval do
        def capture_haml(&block)
          block.call
        end
      end

      @parent = create(:category, name: 'Parent')
      @child = create(:category, name: 'Child')
      @parent.children << @child

      @ret = described_class.decorate([@parent, @child]).as_nestable_list do |i|
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
