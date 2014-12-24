require 'spec_helper'

RSpec.describe RLetters::Datasets::DocumentEnumerator do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 2, working: true,
                                     user: @user)
  end

  context 'with no custom fields' do
    before(:example) do
      @enum = RLetters::Datasets::DocumentEnumerator.new(@dataset)
    end

    it 'enumerates the documents as expected' do
      expect(WORKING_UIDS).to include(@enum.first.uid)
    end

    it 'does not include term vectors' do
      expect(@enum.first.term_vectors).not_to be
    end

    it 'does not include full text' do
      expect(@enum.first.fulltext).not_to be
    end

    it 'throws if the Solr server fails' do
      stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
      expect {
        @enum.each {}
      }.to raise_error(RuntimeError)
    end
  end

  context 'with term vectors' do
    before(:example) do
      @enum = RLetters::Datasets::DocumentEnumerator.new(@dataset, term_vectors: true)
    end

    it 'returns the term vectors' do
      expect(@enum.first.term_vectors).to be
    end

    it 'does not include full text' do
      expect(@enum.first.fulltext).not_to be
    end
  end

  context 'with fulltext fields' do
    before(:example) do
      @enum = RLetters::Datasets::DocumentEnumerator.new(@dataset, fulltext: true)
    end

    it 'returns the full text' do
      expect(@enum.first.fulltext).to be
    end

    it 'does not include term vectors' do
      expect(@enum.first.term_vectors).not_to be
    end
  end

  context 'with custom fields' do
    before(:example) do
      @enum = RLetters::Datasets::DocumentEnumerator.new(@dataset, fl: 'year')
    end

    it 'only includes the custom fields' do
      expect(@enum.first.year).to_not be_empty
      expect(@enum.first.title).to be_nil
    end
  end
end
