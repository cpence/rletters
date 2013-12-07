# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Documents::Serializers::RIS do

  context 'when serializing a single document' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @str = @doc.to_ris
    end

    it 'creates good RIS' do
      expect(@str).to be_start_with("TY  - JOUR\n")
      expect(@str).to include('AU  - Botero,Carlos A.')
      expect(@str).to include('AU  - Mudge,Andrew E.')
      expect(@str).to include('AU  - Koltz,Amanda M.')
      expect(@str).to include('AU  - Hochachka,Wesley M.')
      expect(@str).to include('AU  - Vehrencamp,Sandra L.')
      expect(@str).to include('TI  - How Reliable are the Methods for Estimating Repertoire Size?')
      expect(@str).to include('JO  - Ethology')
      expect(@str).to include('VL  - 114')
      expect(@str).to include('SP  - 1227')
      expect(@str).to include('EP  - 1238')
      expect(@str).to include('PY  - 2008')
      expect(@str).to be_end_with("ER  - \n")
    end
  end

  context 'when serializing an array of documents' do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      @docs = [doc, doc]
      @str = @docs.to_ris
    end

    it 'creates good RIS' do
      expect(@str).to be_start_with("TY  - JOUR\n")
      expect(@str).to include("ER  - \nTY  - JOUR\n")
    end
  end

end
