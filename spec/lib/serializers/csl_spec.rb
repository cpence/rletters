# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::CSL do

  before(:each) do
    @doc = FactoryGirl.build(:full_document)
  end

  context 'when fetching a single document' do
    before(:each) do
      @csl = @doc.to_csl
    end

    it 'creates good CSL' do
      expect(@csl['type']).to eq('article-journal')
      expect(@csl['author'][0]['family']).to eq('Botero')
      expect(@csl['author'][1]['given']).to eq('Andrew E.')
      expect(@csl['author'][2]['family']).to eq('Koltz')
      expect(@csl['title']).to eq('How Reliable are the Methods for Estimating Repertoire Size?')
      expect(@csl['container-title']).to eq('Ethology')
      expect(@csl['issued']['date-parts'][0][0]).to eq(2008)
      expect(@csl['volume']).to eq('114')
      expect(@csl['page']).to eq('1227-1238')
    end
  end

  context 'when formatting CSL citations' do
    it 'formats with all the CSL style files' do
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'American Psychological Association 6th Edition'))).to eq('Botero, C. A., Mudge, A. E., Koltz, A. M., Hochachka, W. M., &#38; Vehrencamp, S. L. (2008). How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i>, <i>114</i>, 1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'American Political Science Association'))).to eq('Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'American Sociological Association'))).to eq('Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114:1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'Chicago Manual of Style (Author-Date format)'))).to eq('Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'Chicago Manual of Style (Note with Bibliography)'))).to eq('Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114 (2008): 1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'Harvard Reference format 1 (Author-Date)'))).to eq('Botero, C.A., Mudge, A.E., Koltz, A.M., Hochachka, W.M. &#38; Vehrencamp, S.L., 2008. How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i>, 114, 1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'IEEE'))).to eq('C.A. Botero, A.E. Mudge, A.M. Koltz, W.M. Hochachka and S.L. Vehrencamp, “How Reliable are the Methods for Estimating Repertoire Size?”, <i>Ethology</i>, vol. 114, 2008, 1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'Modern Humanities Research Association (Note with Bibliography)'))).to eq('Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp, ‘How Reliable Are the Methods For Estimating Repertoire Size?’, <i>Ethology</i>, 114 (2008), 1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'Modern Language Association'))).to eq('Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114 (2008): 1227-1238. Print.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'Nature Journal'))).to eq('Botero, C.A., Mudge, A.E., Koltz, A.M., Hochachka, W.M. &#38; Vehrencamp, S.L. How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i> <b>114</b>, 1227-1238 (2008).')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'National Library of Medicine'))).to eq('Botero CA, Mudge AE, Koltz AM, Hochachka WM, Vehrencamp SL. How Reliable are the Methods for Estimating Repertoire Size?. Ethology 2008;114:1227-1238.')
      expect(@doc.to_csl_entry(CslStyle.find_by!(name: 'Vancouver'))).to eq('Botero CA, Mudge AE, Koltz AM, Hochachka WM, Vehrencamp SL. How Reliable are the Methods for Estimating Repertoire Size?. Ethology. 2008;114:1227–38.')
    end

    it 'fetches CSL styles over HTTP',
       vcr: { cassette_name: 'csl_from_github' } do
      entry = @doc.to_csl_entry('https://raw.github.com/citation-style-language/styles/master/science.csl')
      expect(entry.to_s).to eq('C. A. Botero, A. E. Mudge, A. M. Koltz, W. M. Hochachka, S. L. Vehrencamp, How Reliable are the Methods for Estimating Repertoire Size?, <i>Ethology</i> <b>114</b>, 1227-1238 (2008).')
    end

    it 'throws an error if you provide a strange argument' do
      expect {
        @doc.to_csl_entry(37)
      }.to raise_error(ArgumentError)
    end
  end

end
