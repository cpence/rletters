# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'datasets/index' do

  it 'has a reference somewhere to the task list' do
    # Need to render the layout in order to get the page-JS
    render template: 'datasets/index', layout: 'layouts/application'
    expect(rendered).to include(dataset_list_datasets_path)
  end

end
