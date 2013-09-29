# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'craig_zeta/_start' do

  before(:each) do
    register_job_view_path

    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)
  end

  context 'with only one dataset' do
    before(:each) do
      @dataset = FactoryGirl.create(:dataset, user: @user)
    end

    it 'has no links' do
      render
      expect(rendered).not_to have_tag('a')
    end
  end

  context 'with two datasets' do
    before(:each) do
      @dataset = FactoryGirl.create(:dataset, user: @user)
      @dataset_2 = FactoryGirl.create(:dataset, user: @user)
    end

    it 'has a link to the parameters page' do
      render

      link = url_for(controller: 'datasets',
                     action: 'task_view',
                     view: 'params',
                     class: 'CraigZeta',
                     id: @dataset.to_param)

      expect(rendered).to have_tag("a[href='#{link}']")
    end
  end

end
