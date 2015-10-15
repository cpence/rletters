require 'rails_helper'

RSpec.describe RLetters::Analysis::CountArticlesByField do
  describe '#call' do
    context 'without a dataset' do
      before(:example) do
        @called_sub_100 = false
        @called_100 = false

        analyzer = described_class.new(
          field: :year,
          progress: lambda do |p|
            if p < 100
              @called_sub_100 = true
            else
              @called_100 = true
            end
          end)
        @counts = analyzer.call
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
        analyzer = described_class.new(field: :year)
        expect(analyzer.call).to eq({})
      end
    end

    context 'with a dataset' do
      before(:example) do
        @user = create(:user)
        @dataset = create(:full_dataset, entries_count: 10, working: true,
                                         user: @user)

        @called_sub_100 = false
        @called_100 = false

        analyzer = described_class.new(
          field: :year,
          dataset: @dataset,
          progress: lambda do |p|
            if p < 100
              @called_sub_100 = true
            else
              @called_100 = true
            end
          end)
        @counts = analyzer.call
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
        analyzer = described_class.new(field: :year, dataset: @dataset)
        expect(analyzer.call).to eq({})
      end
    end
  end
end
