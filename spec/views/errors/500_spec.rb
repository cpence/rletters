# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'errors/500' do
  it 'renders' do
    expect {
      render
    }.to_not raise_error
  end

  it 'includes the error image' do
    render
    expect(rendered).to include(UploadedAsset.url_for('error-watermark'))
  end
end
