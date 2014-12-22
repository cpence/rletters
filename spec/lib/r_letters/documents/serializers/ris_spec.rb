# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::Serializers::RIS do

  context 'when serializing a single document' do
    before(:example) do
      @doc = build(:full_document)
      @str = described_class.new(@doc).serialize
    end

    it 'creates good RIS' do
      expect(@str).to start_with("TY  - JOUR\n")
      expect(@str).to include('AU  - Dickens,C.')
      expect(@str).to include('TI  - A Tale of Two Cities')
      expect(@str).to include('JO  - Actually a Novel')
      expect(@str).to include('VL  - 1')
      expect(@str).to include('IS  - 1')
      expect(@str).to include('SP  - 1')
      expect(@str).not_to include('EP  - ')
      expect(@str).to include('PY  - 1859')
      expect(@str).to end_with("ER  - \n")
    end
  end

  context 'when serializing an array of documents' do
    before(:example) do
      doc = build(:full_document)
      @docs = [doc, doc]
      @str = described_class.new(@docs).serialize
    end

    it 'creates good RIS' do
      expect(@str).to start_with("TY  - JOUR\n")
      expect(@str).to include("ER  - \nTY  - JOUR\n")
    end
  end

end
