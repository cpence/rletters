# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'datasets/delete' do

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, entries_count: 10)
    assign(:dataset, @dataset)
    params[:id] = @dataset.to_param
    render
  end

  it 'has a form to delete the dataset' do
    expect(rendered).to have_tag("form[action='#{dataset_path(@dataset)}']")
    expect(rendered).to have_tag('input[name=_method][value=delete]')
  end

  it 'has a confirm button' do
    expect(rendered).to have_tag('input[name=commit]')
  end

  it 'has a cancel button' do
    expect(rendered).to have_tag('input[name=cancel]')
  end

end
