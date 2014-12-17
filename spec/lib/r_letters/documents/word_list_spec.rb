# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Documents::WordList do
  before(:example) do
    @doc = build(:full_document)
    allow(Document).to receive(:find_by!).and_return(@doc)
  end

  context 'with 1-grams' do
    before(:example) do
      @stemmer = described_class.new
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'provides the words in order' do
      expect(@list.take(5)).to eq(['lorem', 'ipsum', 'dolor', 'sit', 'amet'])
    end

    it 'gets the corpus dfs' do
      # All of these are 1 in our fixture, as they were generated in a single
      # document Solr server.
      expect(@stemmer.corpus_dfs['lorem']).to eq(1)
    end
  end

  context 'with 2-grams' do
    before(:example) do
      @stemmer = described_class.new(ngrams: 2)
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'provides a list of two-grams' do
      expect(@list.first).to eq('lorem ipsum')
      expect(@list.second).to eq('ipsum dolor')
    end

    it 'does not make any non-2-grams' do
      @list.each do |g|
        expect(g.split.size).to eq(2)
      end
    end
  end

  context 'with stemming' do
    before(:example) do
      @stemmer = described_class.new(stemming: :stem)
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'calls #stem on each word' do
      expect(@list).to include('exercit')
    end

    it 'calls #stem on the corpus dfs' do
      expect(@stemmer.corpus_dfs['exercit']).to be
    end
  end

  context 'with lemmatization' do
    before(:each) do
      @old_path = Admin::Setting.nlp_tool_path
      Admin::Setting.nlp_tool_path = 'stubbed'

      @stemmer = described_class.new(stemming: :lemma)
      words = build(:lemmatizer).words
      expect(RLetters::Analysis::NLP).to receive(:lemmatize_words).and_return(words)

      @list = @stemmer.words_for(@doc.uid)
    end

    after(:each) do
      Admin::Setting.nlp_tool_path = @old_path
    end

    it 'calls the lemmatizer' do
      expect(@list).to include('varem')
      expect(@list).to include('opsom')
    end

    it 'does not leave un-lemmatized words' do
      expect(@list).not_to include('lorem')
    end
  end
end
