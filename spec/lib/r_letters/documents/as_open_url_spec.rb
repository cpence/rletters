# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::AsOpenURL do
  context 'when getting OpenURL link for a single document' do
    before(:example) do
      @doc = build(:full_document)
      @params = described_class.new(@doc).params
    end

    it 'creates good OpenURL params' do
      expect(@params).to eq(
        'ctx_ver=Z39.88-2004&rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3A' \
        'mtx%3Ajournal&rft.genre=article&' \
        'rft_id=info:doi%2F10.5678%2Fdickens&' \
        'rft.atitle=A+Tale+of+Two+Cities&rft.title=Actually+a+Novel&' \
        'rft.date=1859&rft.volume=1&rft.issue=1&rft.spage=1&rft.aufirst=C.&' \
        'rft.aulast=Dickens'
      )
    end
  end
end
