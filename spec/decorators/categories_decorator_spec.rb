require 'rails_helper'

RSpec.describe CategoriesDecorator, type: :decorator do
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

      @ret = described_class.decorate([@category, @child]).link_tree
    end

    it 'returns a proper tree' do
      expect(@ret).to have_selector('li', text: 'Parent')
      expect(@ret).to have_selector('li ul li', text: 'Child')
    end
  end
end
