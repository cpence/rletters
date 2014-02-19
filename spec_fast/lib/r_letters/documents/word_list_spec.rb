# -*- encoding : utf-8 -*-
require 'core_ext/hash/compact'
require 'active_support/core_ext/hash/reverse_merge'

require 'r_letters/documents/word_list'
require 'support/doubles/document_fulltext'
require 'support/doubles/stanford_nlp_lemmatizer'

describe RLetters::Documents::WordList do
  before(:each) do
    @doc = stub_document_fulltext
  end

  context 'with 1-grams' do
    before(:each) do
      @stemmer = described_class.new
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'provides the words in order' do
      expect(@list.take(6)).to eq(['it', 'was', 'the', 'best', 'of', 'times'])
    end

    it 'gets the corpus dfs' do
      expect(@stemmer.corpus_dfs['it']).to eq(1)
    end
  end

  context 'with 2-grams' do
    before(:each) do
      @stemmer = described_class.new(ngrams: 2)
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'provides a list of two-grams' do
      expect(@list.first).to eq('it was')
      expect(@list.last).to eq('comparison only')
    end

    it 'does not make any non-2-grams' do
      @list.each do |g|
        expect(g.split.size).to eq(2)
      end
    end
  end

  context 'with stemming' do
    before(:each) do
      # Stubs don't work on frozen strings, which is what hash keys are
      String.class_eval do
        def stem; return self + 'WHAT'; end
      end

      @stemmer = described_class.new(stemming: :stem)
      @list = @stemmer.words_for(@doc.uid)
    end

    after(:each) do
      # Remove our hack-mock
      String.class_eval do
        remove_method :stem
      end
    end

    it 'calls #stem on each word' do
      expect(@list).to include('itWHAT')
    end

    it 'calls #stem on the corpus dfs' do
      expect(@stemmer.corpus_dfs['itWHAT']).to be
    end
  end

  context 'with lemmatization' do
    before(:each) do
      stub_stanford_nlp_lemmatizer
      @stemmer = described_class.new(stemming: :lemma)
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'calls the lemmatizer' do
      expect(@list).to include('be')
    end

    it 'does not leave un-lemmatized words' do
      expect(@list).not_to include('was')
    end

    it 'calls the lemmatizer when setting the corpus dfs' do
      # Patch into the mocked lemmatizer and make sure it gets called
      expect(StanfordCoreNLP::Annotation).to receive(:new).with('it').and_call_original
      expect(StanfordCoreNLP::Annotation).to receive(:new).at_least(1).times.and_call_original

      @stemmer.corpus_dfs
    end
  end
end
