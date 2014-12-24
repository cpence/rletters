require 'spec_helper'

RSpec.describe RLetters::Analysis::CountArticlesByField do
  describe '#counts_for' do
    context 'without a dataset' do
      before(:context) do
        @called_sub_100 = false
        @called_100 = false

        counter = described_class.new(nil, lambda do |p|
          if p < 100
            @called_sub_100 = true
          else
            @called_100 = true
          end
        end)
        @counts = counter.counts_for(:year)
      end

      it 'gets the values for the whole corpus' do
        expect(@counts['2009']).to eq(224)
        expect(@counts['2007']).to eq(42)
      end

      it 'calls the progress function with under and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end

    context 'without a dataset, with Solr failure' do
      it 'is empty' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(described_class.new.counts_for(:year)).to eq({})
      end
    end

    context 'with a dataset' do
      before(:context) do
        @user = create(:user)
        @dataset = create(:full_dataset, entries_count: 10, working: true,
                                         user: @user)

        @called_sub_100 = false
        @called_100 = false

        counter = described_class.new(@dataset, lambda do |p|
          if p < 100
            @called_sub_100 = true
          else
            @called_100 = true
          end
        end)
        @counts = counter.counts_for(:year)
      end

      it 'gets the values for the dataset' do
        expect(@counts.size).to eq(1)
        expect(@counts['2009']).to eq(10)
      end

      it 'calls the progress function with under and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end

    context 'without a dataset, with Solr failure' do
      it 'is empty' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(described_class.new(@dataset).counts_for(:year)).to eq({})
      end
    end
  end
end
