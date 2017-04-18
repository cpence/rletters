require 'rails_helper'

RSpec.describe RLetters::Analysis::Frequency::FromPosition do
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, num_docs: 10, user: @user)
  end

  context 'with plain onegrams analysis' do
    before(:example) do
      @called_sub_100 = false
      @called_100 = false

      @analyzer = described_class.call(
        dataset: @dataset,
        split_across: false,
        progress: lambda do |p|
          if p < 100
            @called_sub_100 = true
          else
            @called_100 = true
          end
        end)
    end

    describe '#num_words' do
      it 'saves blocks' do
        expect(@analyzer.blocks).to be_an(Array)
        expect(@analyzer.blocks[0]).to be_a(Hash)
        expect(@analyzer.blocks[0].first[0]).to be_a(String)
        expect(@analyzer.blocks[0].first[1]).to be_an(Integer)

        expect(@analyzer.num_dataset_types).to be
        expect(@analyzer.num_dataset_tokens).to be
      end

      it 'analyzes every word' do
        num_words = @analyzer.blocks.flat_map(&:keys).uniq.count
        expect(num_words).to eq(@analyzer.num_dataset_types)
      end

      it 'does not include words without hits' do
        @analyzer.blocks.each do |b|
          b.values.each do |v|
            expect(v.to_i).not_to eq(0)
          end
        end
      end
    end

    describe '#block_stats' do
      it 'includes name, types, and tokens' do
        expect(@analyzer.block_stats[0][:name]).to be
        expect(@analyzer.block_stats[0][:types]).to be
        expect(@analyzer.block_stats[0][:tokens]).to be
      end
    end

    describe '#df_in_dataset' do
      it 'includes (at least) all the words in the list' do
        @analyzer.word_list.each do |w|
          expect(@analyzer.df_in_dataset[w]).to be
        end
      end

      it 'returns correct values' do
        expect(@analyzer.df_in_dataset['malaria']).to eq(1)
        expect(@analyzer.df_in_dataset['disease']).to eq(8)
      end
    end

    describe '#df_in_corpus' do
      it 'includes (at least) all the words in the list' do
        @analyzer.word_list.each do |w|
          expect(@analyzer.df_in_corpus[w]).to be
        end
      end

      it 'returns the right corpus values' do
        expect(@analyzer.df_in_corpus['malaria']).to eq(128)
        expect(@analyzer.df_in_corpus['disease']).to eq(1104)
      end
    end

    describe 'progress reporting' do
      it 'calls the progress function with under and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end
  end

  describe '#num_words' do
    context 'with num_words negative' do
      it 'throws an error' do
        expect {
          @analyzer = described_class.call(
            dataset: @dataset,
            split_across: false,
            num_words: -1,
            num_blocks: 1)
        }.to raise_error(ArgumentError)
      end
    end

    context 'with num_words set to 10' do
      before(:example) do
        @analyzer = described_class.call(dataset: @dataset,
                                         split_across: false,
                                         num_words: 10)
      end

      it 'includes a total of ten words' do
        expect(@analyzer.blocks.flat_map(&:keys).uniq.count).to eq(10)
      end
    end

    context 'with all set' do
      before(:example) do
        @analyzer = described_class.call(dataset: @dataset,
                                         split_across: false,
                                         num_words: 3,
                                         all: true,
                                         num_blocks: 1)
      end

      it 'includes all the words' do
        expect(@analyzer.block_stats[0][:types]).to eq(@analyzer.blocks[0].size)
      end
    end
  end

  describe '#inclusion_list' do
    context 'with one-grams' do
      before(:example) do
        @analyzer = described_class.call(dataset: @dataset,
                                         split_across: false,
                                         inclusion_list: 'malaria disease')
      end

      it 'only includes those words' do
        expect(@analyzer.blocks[0].keys - %w(malaria disease)).to be_empty
      end
    end

    context 'with n-grams' do
      before(:example) do
        @analyzer = described_class.call(dataset: @dataset,
                                         ngrams: 3,
                                         inclusion_list: 'malaria')
      end

      it 'produces ngrams that all contain malaria' do
        expect(@analyzer.blocks[0].size).to be > 0
        @analyzer.blocks[0].each do |k, _|
          expect(k.split).to include('malaria')
        end
      end
    end
  end

  describe '#exclusion_list' do
    context 'with one-grams' do
      before(:example) do
        @analyzer = described_class.call(dataset: @dataset,
                                         split_across: false,
                                         exclusion_list: 'a the')
      end

      it 'does not include those words' do
        expect(@analyzer.blocks[0].keys).not_to include('a')
        expect(@analyzer.blocks[0].keys).not_to include('the')
      end

      it 'includes some words' do
        expect(@analyzer.blocks[0].keys).not_to be_empty
      end
    end

    context 'with n-grams' do
      before(:example) do
        @analyzer = described_class.call(dataset: @dataset,
                                         ngrams: 3,
                                         exclusion_list: 'diseases')
      end

      it 'produces ngrams that do not contain diseases' do
        @analyzer.blocks[0].each do |k, _|
          expect(k.split).not_to include('diseases')
        end
      end
    end

    context 'with n-grams and both an inclusion and exclusion list' do
      before(:example) do
        @analyzer = described_class.call(dataset: @dataset,
                                         ngrams: 3,
                                         inclusion_list: 'decade',
                                         exclusion_list: 'remains')
      end

      it 'combines the lists in the right way' do
        @analyzer.blocks[0].each do |k, _|
          expect(k.split).not_to include('remains')
          expect(k.split).to include('decade')
        end
      end
    end

    context 'with n-grams and both an inclusion and stop list' do
      before(:example) do
        @analyzer = described_class.call(dataset: @dataset,
                                         ngrams: 3,
                                         inclusion_list: 'diseases',
                                         stop_list: create(:stop_list))
      end

      it 'combines the lists in the right way' do
        @analyzer.blocks[0].each do |k, _|
          expect(k.split).to include('diseases')
          expect(k.split).not_to include('the')
          expect(k.split).not_to include('a')
          expect(k.split).not_to include('an')
        end
      end
    end
  end

  describe '#stop_list' do
    before(:example) do
      @list = create(:stop_list)
      @analyzer = described_class.call(dataset: @dataset,
                                       split_across: false,
                                       stop_list: @list)
    end

    it 'does not include "a" and "the"' do
      expect(@analyzer.blocks[0].keys).not_to include('a')
      expect(@analyzer.blocks[0].keys).not_to include('the')
    end

    it 'includes some words' do
      expect(@analyzer.blocks[0].keys).not_to be_empty
    end
  end

  describe '#word_list' do
    before(:example) do
      @analyzer = described_class.call(dataset: @dataset,
                                       split_across: false,
                                       num_words: 10)
    end

    it 'only includes the requested number of words' do
      expect(@analyzer.word_list.size).to eq(10)
    end

    it 'analyzes those words in the blocks when present' do
      @analyzer.blocks.each do |b|
        expect(b.keys - @analyzer.word_list).to be_empty
      end
    end
  end

  describe '#tf_in_dataset' do
    before(:example) do
      @analyzer = described_class.call(dataset: @dataset)
    end

    it 'includes (at least) all the words in the list' do
      @analyzer.word_list.each do |w|
        expect(@analyzer.tf_in_dataset[w]).to be
      end
    end

    it 'returns the same values as a single-block analysis' do
      @analyzer.word_list.each do |w|
        expect(@analyzer.blocks[0][w]).to eq(@analyzer.tf_in_dataset[w])
      end
    end
  end
end
