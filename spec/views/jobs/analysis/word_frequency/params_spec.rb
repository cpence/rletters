# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'word_frequency/params' do

  before(:each) do
    register_job_view_path

    @dataset = FactoryGirl.create(:dataset)
    allow(view).to receive(:current_user).and_return(@dataset.user)
  end

  it 'has an input for the block size' do
    render
    expect(rendered).to have_tag("input[name='job_params[block_size]']")
  end

end
