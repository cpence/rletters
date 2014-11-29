# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::RIS do

  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document)
      @str = described_class.new(@doc).serialize
    end

    it 'creates good RIS' do
      expect(@str).to be_start_with("TY  - JOUR\n")
      expect(@str).to include('AU  - One,A.')
      expect(@str).to include('AU  - Two,B.')
      expect(@str).to include('TI  - Test Title')
      expect(@str).to include('JO  - Journal')
      expect(@str).to include('VL  - 10')
      expect(@str).to include('IS  - 20')
      expect(@str).to include('SP  - 100')
      expect(@str).to include('EP  - 200')
      expect(@str).to include('PY  - 2010')
      expect(@str).to be_end_with("ER  - \n")
    end
  end

  context 'when serializing an array of documents' do
    before(:example) do
      doc = build(:full_document)
      @docs = [doc, doc]
      @str = described_class.new(@docs).serialize
    end

    it 'creates good RIS' do
      expect(@str).to be_start_with("TY  - JOUR\n")
      expect(@str).to include("ER  - \nTY  - JOUR\n")
    end
  end

end
