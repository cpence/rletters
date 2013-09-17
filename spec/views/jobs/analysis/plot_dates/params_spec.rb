# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'plot_dates/params' do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:dataset)
    allow(view).to receive(:current_user).and_return(@dataset.user)
  end

  it 'has a checkbox for the normalization parameters' do
    render
    expect(rendered).to have_tag("select[name='job_params[normalize_doc_counts]']")
  end

end
