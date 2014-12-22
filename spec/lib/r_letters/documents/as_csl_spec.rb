# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::AsCSL do
  before(:example) do
    @doc = build(:full_document)
    @as_csl = described_class.new(@doc)
  end

  context 'when fetching a single document' do
    before(:example) do
      @csl = @as_csl.citeproc_item
    end

    it 'creates good CSL' do
      expect(@csl.type).to eq('article-journal')
      expect(@csl.author[0].family).to eq('Dickens')
      expect(@csl.author[0].given).to eq('C.')
      expect(@csl.title).to eq('A Tale of Two Cities')
      expect(@csl.container_title).to eq('Actually a Novel')
      expect(@csl.issued.to_date).to eq(Date.new(1859))
      expect(@csl.volume).to eq('1')
      expect(@csl.issue).to eq('1')
      expect(@csl.page).to eq('1')
    end
  end

  context 'when formatting CSL citations' do
    before(:example) do
      @style = double(style: <<eos)
<style xmlns="http://purl.org/net/xbiblio/csl"  class="in-text" version="1.0">
  <info>
    <id />
    <title />
    <updated>2009-08-10T04:49:00+09:00</updated>
  </info>
  <citation>
    <layout>
      <names variable="author">
        <name />
      </names>
    </layout>
  </citation>
  <bibliography>
    <layout>
      <names variable="author">
        <name />
      </names>
    </layout>
  </bibliography>
</style>
eos
    end

    it 'formats with a CSL style' do
      expect(@as_csl.entry(@style)).to eq('C. Dickens')
    end

    it 'throws an error if you provide a strange argument' do
      expect {
        @as_csl.entry(37)
      }.to raise_error(NameError)
    end
  end
end
