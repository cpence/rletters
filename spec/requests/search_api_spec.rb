# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'Search API' do
  it 'loads a basic search successfully' do
    get '/search', format: :json

    expect(response).to be_success
    expect(response.content_type).to eq('application/json')

    expect(json['results']['num_hits']).to eq(1043)
    expect(json['results']['documents'].count).to eq(10)

    expect(json['results']['solr_params']['q']).to eq('*:*')
    expect(json['results']['solr_params']['defType']).to eq('lucene')
    expect(json['results']['solr_params']['start']).to eq('0')
    expect(json['results']['solr_params']['rows']).to eq('10')
  end

  it 'loads faceted searches correctly' do
    get '/search', fq: ['authors_facet:"J. C. Crabbe"'], format: :json

    expect(response).to be_success
    expect(json['results']['num_hits']).to eq(9)
    expect(json['results']['solr_params']['fq']).to eq('authors_facet:"J. C. Crabbe"')
  end

  it 'loads document details correctly' do
    get '/search', q: 'doi:"10.1111/j.1439-0310.2010.01865.x"',
                   precise: true,
                   format: :json

    expect(response).to be_success
    expect(json['results']['num_hits']).to eq(1)

    doc = json['results']['documents'][0]
    expect(doc).to be
    expect(doc['doi']).to eq('10.1111/j.1439-0310.2010.01865.x')
    expect(doc['license']).to eq('© Blackwell Verlag GmbH')
    expect(doc['authors']).to eq('Petr Kovařík, Václav Pavel')
    expect(doc['journal']).to eq('Ethology')
    expect(doc['volume']).to eq('117')
  end
end
