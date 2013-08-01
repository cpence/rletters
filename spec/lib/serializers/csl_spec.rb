# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::CSL do

  before(:each) do
    @doc = FactoryGirl.build(:full_document)
  end

  context "when fetching a single document" do
    before(:each) do
      @csl = @doc.to_csl
    end

    it "creates good CSL" do
      @csl['type'].should eq('article-journal')
      @csl['author'][0]['family'].should eq('Botero')
      @csl['author'][1]['given'].should eq('Andrew E.')
      @csl['author'][2]['family'].should eq('Koltz')
      @csl['title'].should eq('How Reliable are the Methods for Estimating Repertoire Size?')
      @csl['container-title'].should eq('Ethology')
      @csl['issued']['date-parts'][0][0].should eq(2008)
      @csl['volume'].should eq('114')
      @csl['page'].should eq('1227-1238')
    end
  end

  context "when formatting CSL citations" do
    it "formats with all the CSL style files" do
      @doc.to_csl_entry(CslStyle.find_by_name("American Psychological Association 6th Edition")).should eq("Botero, C. A., Mudge, A. E., Koltz, A. M., Hochachka, W. M., &#38; Vehrencamp, S. L. (2008). How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i>, <i>114</i>, 1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('American Political Science Association')).should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('American Sociological Association')).should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114:1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('Chicago Manual of Style (Author-Date format)')).should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('Chicago Manual of Style (Note with Bibliography)')).should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114 (2008): 1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('Harvard Reference format 1 (Author-Date)')).should eq("Botero, C.A., Mudge, A.E., Koltz, A.M., Hochachka, W.M. &#38; Vehrencamp, S.L., 2008. How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i>, 114, 1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('IEEE')).should eq("C.A. Botero, A.E. Mudge, A.M. Koltz, W.M. Hochachka and S.L. Vehrencamp, “How Reliable are the Methods for Estimating Repertoire Size?”, <i>Ethology</i>, vol. 114, 2008, 1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('Modern Humanities Research Association (Note with Bibliography)')).should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp, ‘How Reliable Are the Methods For Estimating Repertoire Size?’, <i>Ethology</i>, 114 (2008), 1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('Modern Language Association')).should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114 (2008): 1227-1238. Print.")
      @doc.to_csl_entry(CslStyle.find_by_name('Nature Journal')).should eq("Botero, C.A., Mudge, A.E., Koltz, A.M., Hochachka, W.M. &#38; Vehrencamp, S.L. How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i> <b>114</b>, 1227-1238 (2008).")
      @doc.to_csl_entry(CslStyle.find_by_name('National Library of Medicine')).should eq("Botero CA, Mudge AE, Koltz AM, Hochachka WM, Vehrencamp SL. How Reliable are the Methods for Estimating Repertoire Size?. Ethology 2008;114:1227-1238.")
      @doc.to_csl_entry(CslStyle.find_by_name('Vancouver')).should eq("Botero CA, Mudge AE, Koltz AM, Hochachka WM, Vehrencamp SL. How Reliable are the Methods for Estimating Repertoire Size?. Ethology. 2008;114:1227–38.")
    end

    it "fetches CSL styles over HTTP", vcr: { cassette_name: 'csl_from_github' } do
      entry = @doc.to_csl_entry('https://raw.github.com/citation-style-language/styles/master/science.csl')
      entry.to_s.should eq("C. A. Botero, A. E. Mudge, A. M. Koltz, W. M. Hochachka, S. L. Vehrencamp, How Reliable are the Methods for Estimating Repertoire Size?, <i>Ethology</i> <b>114</b>, 1227-1238 (2008).")
    end
  end

end
