require 'rails_helper'

RSpec.describe RLetters::Datasets::AddSearch do
  before(:example) do
    @user = create(:user)
    @dataset = create(:dataset, user: @user)
  end

  context 'with a basic search' do
    before(:example) do
      @called_sub_100 = false
      @called_100 = false

      @search = RLetters::Solr::Connection.search(q: '*:*', def_type: 'lucene')
      @adder = described_class.call(dataset: @dataset,
                                    q: '*:*',
                                    def_type: 'lucene',
                                    progress: lambda do |p|
                                      if p < 100
                                        @called_sub_100 = true
                                      else
                                        @called_100 = true
                                      end
                                    end)
    end

    it 'fills in the dataset' do
      expect(@dataset.entries.size).to eq(1502)
    end

    it 'sets the fetch tag' do
      expect(@dataset.fetch).to be true
    end

    it 'calls the progress reporter' do
      expect(@called_sub_100).to be true
      expect(@called_100).to be true
    end
  end
end
