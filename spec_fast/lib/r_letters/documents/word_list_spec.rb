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
      @list = described_class.new.words_for(@doc.uid)
    end

    it 'provides the words in order' do
      expect(@list.take(6)).to eq(['it', 'was', 'the', 'best', 'of', 'times'])
    end
  end

  context 'with 2-grams' do
    before(:each) do
      @list = described_class.new(ngrams: 2).words_for(@doc.uid)
    end

    it 'provides a list of two-grams' do
      expect(@list.first).to eq('it was')
      expect(@list.last).to eq('comparison only')
    end

    it 'does not make any non-2-grams' do
      @list.each do |g|
        expect(g.split.count).to eq(2)
      end
    end
  end

  context 'with stemming' do
    before(:each) do
      # Stubs don't work on frozen strings, which is what hash keys are
      String.class_eval do
        def stem; return self + 'WHAT'; end
      end

      @list = described_class.new(stemming: :stem).words_for(@doc.uid)
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
  end

  context 'with lemmatization' do
    before(:each) do
      stub_stanford_nlp_lemmatizer
      @list = described_class.new(stemming: :lemma).words_for(@doc.uid)
    end

    it 'calls the lemmatizer' do
      expect(@list).to include('be')
    end

    it 'does not leave un-lemmatized words' do
      expect(@list).not_to include('was')
    end
  end
end
