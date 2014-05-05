# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RLetters::Documents::WordList do
  before(:each) do
    @doc = build(:full_document)
  end

  context 'with 1-grams' do
    before(:each) do
      @stemmer = described_class.new
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'provides the words in order' do
      expect(@list.take(6)).to eq(['ethology', 'how', 'reliable', 'are', 'the', 'methods'])
    end

    it 'gets the corpus dfs' do
      expect(@stemmer.corpus_dfs['ethology']).to eq(579)
    end
  end

  context 'with 2-grams' do
    before(:each) do
      @stemmer = described_class.new(ngrams: 2)
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'provides a list of two-grams' do
      expect(@list.first).to eq('ethology how')
      expect(@list.second).to eq('how reliable')
    end

    it 'does not make any non-2-grams' do
      @list.each do |g|
        expect(g.split.size).to eq(2)
      end
    end
  end

  context 'with stemming' do
    before(:each) do
      @stemmer = described_class.new(stemming: :stem)
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'calls #stem on each word' do
      expect(@list).to include('etholog')
      expect(@list).to include('method')
    end

    it 'calls #stem on the corpus dfs' do
      expect(@stemmer.corpus_dfs['etholog']).to be
      expect(@stemmer.corpus_dfs['method']).to be
    end
  end

  # FIXME: fix the double for this
    # context 'with lemmatization' do
    #   before(:each) do
    #     stub_stanford_nlp_lemmatizer
    #     @stemmer = described_class.new(stemming: :lemma)
    #     @list = @stemmer.words_for(@doc.uid)
    #   end

    #   it 'calls the lemmatizer' do
    #     expect(@list).to include('be')
    #   end

    #   it 'does not leave un-lemmatized words' do
    #     expect(@list).not_to include('was')
    #   end

    #   it 'calls the lemmatizer when setting the corpus dfs' do
    #     # Patch into the mocked lemmatizer and make sure it gets called
    #     expect(StanfordCoreNLP::Annotation).to receive(:new).with('it').and_call_original
    #     expect(StanfordCoreNLP::Annotation).to receive(:new).at_least(1).times.and_call_original

    #     @stemmer.corpus_dfs
    #   end
    # end
end
