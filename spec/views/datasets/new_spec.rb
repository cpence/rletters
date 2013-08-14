# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'datasets/new' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
    allow(view).to receive(:user_signed_in?).and_return(true)

    assign(:dataset, FactoryGirl.build(:dataset, user: @user))
  end

  shared_examples_for 'all new forms' do
    it 'has a name field' do
      expect(rendered).to have_tag('input[name="dataset[name]"]')
    end

    it 'has a filled-in query field' do
      expect(rendered).to have_tag('input[name=q][value="*:*"]')
    end

    it 'has a filled-in query type field' do
      expect(rendered).to have_tag('input[name=defType][value=lucene]')
    end
  end

  context 'when no facet query fields are specified' do
    before(:each) do
      params[:q] = '*:*'
      params[:fq] = nil
      params[:defType] = 'lucene'

      render
    end

    it_should_behave_like 'all new forms'

    it 'has no facet query fields' do
      expect(rendered).not_to have_tag('input[name="fq[]"]')
    end
  end

  context 'when facet query fields are specified' do
    before(:each) do
      params[:q] = '*:*'
      params[:fq] = ['authors_facet:Test']
      params[:defType] = 'lucene'

      render
    end

    it_should_behave_like 'all new forms'

    it 'has facet query fields' do
      expect(rendered).to have_tag('input[name="fq[]"][value="authors_facet:Test"]')
    end
  end

end
