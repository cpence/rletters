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
      expect(@list.take(5)).to eq(%w(it was the best of))
    end

    it 'gets the corpus dfs' do
      expect(@stemmer.corpus_dfs['it']).to eq(1486)
    end
  end

  context 'with 2-grams' do
    before(:example) do
      @stemmer = described_class.new(ngrams: 2)
      @list = @stemmer.words_for(@doc.uid)
    end

    it 'provides a list of two-grams' do
      expect(@list.first).to eq('it was')
      expect(@list.second).to eq('was the')
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
      expect(@list).to include('wa')
      expect(@list).not_to include('was')
    end

    it 'calls #stem on the corpus dfs' do
      expect(@stemmer.corpus_dfs['wa']).to be
    end
  end

  context 'with lemmatization' do
    before(:example) do
      @old_path = Admin::Setting.nlp_tool_path
      Admin::Setting.nlp_tool_path = 'stubbed'

      @stemmer = described_class.new(stemming: :lemma)
      words = build(:lemmatizer).words
      expect(RLetters::Analysis::NLP).to receive(:lemmatize_words).and_return(words)

      @list = @stemmer.words_for(@doc.uid)
    end

    after(:example) do
      Admin::Setting.nlp_tool_path = @old_path
    end

    it 'calls the lemmatizer' do
      expect(@list.take(3)).to eq(%w(it be the))
    end

    it 'does not leave un-lemmatized words' do
      expect(@list).not_to include('was')
    end
  end
end
