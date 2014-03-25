# -*- encoding : utf-8 -*-
require 'spec_helper'

describe CategoryDecorator do
  before(:each) do
    @category = create(:category)
    @decorated = described_class.decorate(@category)
  end

  describe '#removal_link' do
    it 'works' do
      allow(@decorated).to receive(:toggle_params).and_return({ toggle: true })
      ret = @decorated.removal_link

      expect(ret).to include('<a href="/search?toggle=true">Category: Test Category</a>')
    end
  end

  describe '#link_tree' do
    before(:each) do
      allow(@decorated).to receive(:toggle_params).and_return({ toggle: true })

      @subcat = create(:category)
      @category.children << @subcat
    end

    it 'produces the link for this category' do
      expect(@decorated.link_tree).to include("<a href=\"/search?toggle=true\">")
    end

    it 'calls recursively for the children' do
      expect(CategoryDecorator).to receive(:decorate).with(@subcat).and_return(double(link_tree: ''))
      @decorated.link_tree
    end
  end

  describe '#enabled' do
    it 'works when enabled' do
      Draper::ViewContext.current.params[:categories] = [@category.to_param]
      expect(@decorated.enabled).to be
    end

    it 'works when disabled' do
      expect(@decorated.enabled).not_to be
    end
  end

  describe '#toggle_link' do
    context 'when enabled' do
      it 'works' do
        Draper::ViewContext.current.params[:categories] = [@category.to_param]
        expect(@decorated.toggle_link).to include('<a href="/search">')
      end
    end

    context 'when disabled' do
      it 'works' do
        expect(@decorated.toggle_link).to include("<a href=\"/search?categories%5B%5D=#{@category.to_param}\">")
      end
    end
  end
end
