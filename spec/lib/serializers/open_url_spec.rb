# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::OpenURL do
  
  context "when getting OpenURL link for a single document" do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @params = @doc.to_openurl_params
    end
    
    it "creates good OpenURL params" do
      # FIXME: This is really an awful test, but how can we do it any better?
      @params.should eq("ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A" \
        "mtx%3Ajournal&rft.genre=article&" \
        "rft_id=info:doi%2F10.1111%2Fj.1439-0310.2008.01576.x" \
        "&rft.atitle=How+Reliable+are+the+Methods+for+" \
        "Estimating+Repertoire+Size%3F" \
        "&rft.title=Ethology&rft.date=2008&rft.volume=114" \
        "&rft.spage=1227&rft.epage=1238&rft.aufirst=Carlos+A." \
        "&rft.aulast=Botero&rft.au=Andrew+E.+Mudge" \
        "&rft.au=Amanda+M.+Koltz&rft.au=Wesley+M.+Hochachka" \
        "&rft.au=Sandra+L.+Vehrencamp")
    end
  end
  
end
