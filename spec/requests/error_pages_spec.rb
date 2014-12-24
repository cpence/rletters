require 'spec_helper'

RSpec.describe 'Error pages', type: :request do
  it 'renders the 404 template' do
    get_via_redirect '/asdf/notapage'

    expect(response.code.to_i).to eq(404)
    expect(response).to have_rendered('404')
  end

  it 'renders the 500 template' do
    stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
    get_via_redirect '/search/'

    expect(response.code.to_i).to eq(500)
    expect(response).to have_rendered('500')
  end
end
