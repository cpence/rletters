require 'spec_helper'

RSpec.describe 'Search API', type: :request do
  it 'loads a basic search successfully' do
    get '/search', format: :json

    expect(response).to be_success
    expect(response.content_type).to eq('application/json')

    expect(json['results']['num_hits']).to eq(1502)
    expect(json['results']['documents'].size).to eq(10)

    expect(json['results']['solr_params']['q']).to eq('*:*')
    expect(json['results']['solr_params']['defType']).to eq('lucene')
    expect(json['results']['solr_params']['start']).to eq('0')
    expect(json['results']['solr_params']['rows']).to eq('10')
  end

  it 'loads faceted searches correctly' do
    get '/search', fq: ['authors_facet:"Alan Fenwick"'], format: :json

    expect(response).to be_success
    expect(json['results']['num_hits']).to eq(9)
    expect(json['results']['solr_params']['fq']).to eq('authors_facet:"Alan Fenwick"')
  end

  it 'loads document details correctly' do
    get '/search', q: 'doi:"10.1371/journal.pntd.0000534"',
                   precise: true,
                   format: :json

    expect(response).to be_success
    expect(json['results']['num_hits']).to eq(1)

    doc = json['results']['documents'][0]
    expect(doc).to be
    expect(doc['doi']).to eq('10.1371/journal.pntd.0000534')
    expect(doc['license']).to eq('Creative Commons Attribution (CC BY)')
    expect(doc['authors'].size).to eq(11)
    expect(doc['authors'][0]['full']).to eq('Wenbao Zhang')
    expect(doc['authors'][1]['first']).to eq('Zhuangzhi')
    expect(doc['journal']).to eq('PLoS Neglected Tropical Diseases')
    expect(doc['volume']).to eq('3')
  end
end
