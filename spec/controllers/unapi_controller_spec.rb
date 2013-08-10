# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UnapiController do

  # We're not testing the views separately here, since what matters is how
  # the externally facing API works.
  render_views

  def get_unapi(with_id = false, format = nil)
    if with_id
      @id = FactoryGirl.generate(:working_shasum)
      get :index, { id: @id, format: format }
    else
      get :index
    end

    unless format
      @doc = Nokogiri::XML::Document.parse(response.body)
      @formats = @doc.root.css('format').to_a
    end
  end

  it 'loads the formats page' do
    get_unapi
    expect(response).to be_success
  end

  it 'returns formats page with MIME type application/xml' do
    get_unapi
    expect(response.content_type).to eq('application/xml')
  end

  it 'has a formats tag as its root' do
    get_unapi
    expect(@doc.root.name).to eq('formats')
  end

  it 'has >0 formats in response' do
    get_unapi
    expect(@formats).to have_at_least(1).item
  end

  it 'gives each format a type' do
    get_unapi
    @formats.each do |f|
      expect(f.attributes.keys).to include('type')
    end
  end

  it 'gives each format a name' do
    get_unapi
    @formats.each do |f|
      expect(f.attributes.keys).to include('name')
    end
  end

  it 'returns MIME type application/xml for id request' do
    get_unapi true
    expect(response.content_type).to eq('application/xml')
  end

  it 'responds with 300 for id without format' do
    get_unapi true
    expect(controller.response.response_code).to eq(300)
  end

  it 'returns formats for request for id without format' do
    get_unapi true
    expect(@formats).to have_at_least(1).item
  end

  it 'each format (w/ id) has a type' do
    get_unapi true
    @formats.each do |f|
      expect(f.attributes.keys).to include('type')
    end
  end

  it 'each format (w/ id) has a name' do
    get_unapi true
    @formats.each do |f|
      expect(f.attributes.keys).to include('name')
    end
  end

  it 'responds with 406 for request w/ bad format' do
    get_unapi true, 'css'
    expect(controller.response.response_code).to eq(406)
  end

  it 'succeeds when requesting id and format for all formats' do
    get_unapi true
    @formats.each do |f|
      get_unapi true, f.attributes['name']

      expect(response).to redirect_to(
        controller: 'search',
        action: 'show',
        id: @id,
        format: f.attributes['name'].to_s)
    end
  end

end
