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
    it "creates good CSL citations" do
      @doc.to_csl_entry.to_s.should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.")
    end
    
    it "formats with all our alternate CSL style files" do
      @doc.to_csl_entry('apa.csl').should eq("Botero, C. A., Mudge, A. E., Koltz, A. M., Hochachka, W. M., &#38; Vehrencamp, S. L. (2008). How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i>, <i>114</i>, 1227-1238.")
      @doc.to_csl_entry('apsa.csl').should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.")
      @doc.to_csl_entry('asa.csl').should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114:1227-1238.")
      @doc.to_csl_entry('chicago-author-date.csl').should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. 2008. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114: 1227-1238.")
      @doc.to_csl_entry('chicago-note-bibliography.csl').should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114 (2008): 1227-1238.")
      @doc.to_csl_entry('harvard1.csl').should eq("Botero, C.A., Mudge, A.E., Koltz, A.M., Hochachka, W.M. &#38; Vehrencamp, S.L., 2008. How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i>, 114, 1227-1238.")
      @doc.to_csl_entry('ieee.csl').should eq("C.A. Botero, A.E. Mudge, A.M. Koltz, W.M. Hochachka and S.L. Vehrencamp, “How Reliable are the Methods for Estimating Repertoire Size?”, <i>Ethology</i>,  vol. 114, 2008, 1227-1238.")
      @doc.to_csl_entry('mhra.csl').should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp, ‘How Reliable Are the Methods For Estimating Repertoire Size?’, <i>Ethology</i>, 114 (2008), 1227-1238.")
      @doc.to_csl_entry('mla.csl').should eq("Botero, Carlos A., Andrew E. Mudge, Amanda M. Koltz, Wesley M. Hochachka, and Sandra L. Vehrencamp. “How Reliable are the Methods for Estimating Repertoire Size?”. <i>Ethology</i> 114 (2008): 1227-1238. Print.")
      @doc.to_csl_entry('nature.csl').should eq("Botero, C.A., Mudge, A.E., Koltz, A.M., Hochachka, W.M. &#38; Vehrencamp, S.L. How Reliable are the Methods for Estimating Repertoire Size?. <i>Ethology</i> <b>114</b>, 1227-1238 (2008).")
      @doc.to_csl_entry('nlm.csl').should eq("Botero CA, Mudge AE, Koltz AM, Hochachka WM, Vehrencamp SL. How Reliable are the Methods for Estimating Repertoire Size?. Ethology 2008;114:1227-1238.")
      @doc.to_csl_entry('vancouver.csl').should eq("Botero CA, Mudge AE, Koltz AM, Hochachka WM, Vehrencamp SL. How Reliable are the Methods for Estimating Repertoire Size?. Ethology. 2008;114:1227–38.")
    end
    
    it "fetches CSL styles over HTTP" do
      stub_request(:any, 'https://raw.github.com/citation-style-language/styles/master/science.csl').to_return(File.new(Rails.root.join('spec', 'support', 'webmock', 'csl_response_science.txt')))
      entry = @doc.to_csl_entry('https://raw.github.com/citation-style-language/styles/master/science.csl')
      entry.to_s.should eq("C. A. Botero, A. E. Mudge, A. M. Koltz, W. M. Hochachka, S. L. Vehrencamp, How Reliable are the Methods for Estimating Repertoire Size?, <i>Ethology</i> <b>114</b>, 1227-1238 (2008).")
    end
  end
  
end
