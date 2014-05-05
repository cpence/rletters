# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'support/doubles/document_basic'

describe RLetters::Documents::AsOpenURL do
  context 'when getting OpenURL link for a single document' do
    before(:each) do
      @doc = double_document_basic
      @params = described_class.new(@doc).params
    end

    it 'creates good OpenURL params' do
      expect(@params).to eq(
        'ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A' \
        'mtx%3Ajournal&rft.genre=article' \
        '&rft_id=info:doi%2F10.1234%2F5678' \
        '&rft.atitle=Test+Title' \
        '&rft.title=Journal&rft.date=2010' \
        '&rft.volume=10&rft.issue=20' \
        '&rft.spage=100&rft.epage=200' \
        '&rft.aufirst=A.&rft.aulast=One' \
        '&rft.au=B.+Two'
      )
    end
  end
end
