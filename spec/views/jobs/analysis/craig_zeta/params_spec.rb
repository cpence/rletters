# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'craig_zeta/params' do

  before(:each) do
    register_job_view_path

    @user = FactoryGirl.create(:user)
    allow(view).to receive(:current_user).and_return(@user)

    @dataset = FactoryGirl.create(:dataset, user: @user)
    @dataset_2 = FactoryGirl.create(:dataset, user: @user)
  end

  it 'has a select field for the other dataset' do
    render
    expect(rendered).to have_tag("select[name='job_params[other_dataset_id]']")
  end

  it 'has an option for the other dataset' do
    render
    expect(rendered).to have_tag("option[value='#{@dataset_2.id}']")
  end

  it 'has no option for the first dataset' do
    render
    expect(rendered).not_to have_tag("option[value='#{@dataset.id}']")
  end

end
