require 'rails_helper'

RSpec.describe RLetters::Analysis::CountArticlesByField do
  describe '.call' do
    context 'without a dataset' do
      before(:example) do
        @called_sub_100 = false
        @called_100 = false

        @result = described_class.call(
          field: :year,
          progress: lambda do |p|
            if p < 100
              @called_sub_100 = true
            else
              @called_100 = true
            end
          end)
        @counts = @result.counts
      end

      it 'returns a result object' do
        expect(@result).to be_a(RLetters::Analysis::CountArticlesByField::Result)
        expect(@result.normalize).to be false
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
        expect(described_class.call(field: :year).counts).to eq({})
      end
    end

    context 'with a dataset' do
      before(:example) do
        @user = create(:user)
        @dataset = create(:full_dataset, entries_count: 10, working: true,
                                         user: @user)

        @called_sub_100 = false
        @called_100 = false

        @result = described_class.call(
          field: :year,
          dataset: @dataset,
          progress: lambda do |p|
            if p < 100
              @called_sub_100 = true
            else
              @called_100 = true
            end
          end)
        @counts = @result.counts
      end

      it 'returns a result object' do
        expect(@result).to be_a(RLetters::Analysis::CountArticlesByField::Result)
        expect(@result.normalize).to be false
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

    context 'with a dataset, with Solr failure' do
      it 'is empty' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(described_class.call(field: :year, dataset: @dataset).counts).to eq({})
      end
    end

    context 'when normalizing to a dataset' do
      before(:example) do
        @user = create(:user)
        @dataset = create(:full_dataset, entries_count: 10, working: true,
                                         user: @user)

        @called_sub_100 = false
        @called_100 = false

        @result = described_class.call(
          field: :year,
          dataset: @dataset,
          normalize: true,
          normalization_dataset: @dataset,
          progress: lambda do |p|
            if p < 100
              @called_sub_100 = true
            else
              @called_100 = true
            end
          end)
        @counts = @result.counts
      end

      it 'returns a result object' do
        expect(@result).to be_a(RLetters::Analysis::CountArticlesByField::Result)
        expect(@result.normalize).to be true
        expect(@result.normalization_dataset).to eq(@dataset)
      end

      it 'gets the values for the dataset, normalized (= 1.0)' do
        expect(@counts.size).to eq(1)
        expect(@counts['2009']).to eq(1.0)
      end

      it 'calls the progress function with under and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end

    context 'when normalizing to the corpus' do
      before(:example) do
        @user = create(:user)
        @dataset = create(:full_dataset, entries_count: 10, working: true,
                                         user: @user)

        @called_sub_100 = false
        @called_100 = false

        @result = described_class.call(
          field: :year,
          dataset: @dataset,
          normalize: true,
          progress: lambda do |p|
            if p < 100
              @called_sub_100 = true
            else
              @called_100 = true
            end
          end)
        @counts = @result.counts
      end

      it 'returns a result object' do
        expect(@result).to be_a(RLetters::Analysis::CountArticlesByField::Result)
        expect(@result.normalize).to be true
        expect(@result.normalization_dataset).to be_nil
      end

      it 'gets the values for the dataset' do
        expect(@counts.size).to eq(154)
        expect(@counts['2009']).to be_within(0.01).of(0.0446)
      end

      it 'zeros out intervening years' do
        expect(@counts['1930']).to eq(0)
      end

      it 'calls the progress function with under and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end

    context 'with a non-numeric field' do
      before(:example) do
        @user = create(:user)
        @dataset = create(:full_dataset, entries_count: 10, working: true,
                                         user: @user)

        @result = described_class.call(
          field: :journal_facet,
          dataset: @dataset,
          normalize: true)
        @counts = @result.counts
      end

      it 'zeros out missing values' do
        expect(@counts['Actually a Novel']).to eq(0)
      end
    end
  end
end
