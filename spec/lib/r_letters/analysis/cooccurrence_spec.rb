require 'rails_helper'

RSpec.describe RLetters::Analysis::Cooccurrence do
  it 'raises an error with an invalid scoring method' do
    expect {
      described_class.call(scoring: :nope, dataset: @dataset)
    }.to raise_error(ArgumentError)
  end

  [:log_likelihood, :mutual_information, :t_test].each do |scoring|
    before(:example) do
      @user = create(:user)
      @dataset = create(:full_dataset, num_docs: 2, user: @user)
    end

    describe 'single word analysis' do
      before(:example) do
        @called_sub_100 = false
        @called_100 = false

        @result = described_class.call(
          scoring: scoring,
          dataset: @dataset,
          num_pairs: 10,
          words: 'abstract',
          window: 50,
          progress: lambda do |p|
            if p < 100
              @called_sub_100 = true
            else
              @called_100 = true
            end
          end)
        @grams = @result.cooccurrences
      end

      it 'returns a result object' do
        expect(@result).to be_a(RLetters::Analysis::Cooccurrence::Result)
        expect(@result.scoring).to eq(scoring)
      end

      it 'returns the correct number of grams' do
        expect(@grams.size).to eq(10)
      end

      it 'returns reasonable values for the weights' do
        @grams.each do |g|
          expect(g[1]).to be_a(Numeric)
          expect(g[1]).to be > 0 if g[1].is_a?(Integer)
          expect(g[1]).to be_finite if g[1].is_a?(Float)
        end
      end

      it 'calls progress less than and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end

    describe 'multiple word analysis' do
      before(:example) do
        @result = described_class.call(
          scoring: scoring,
          dataset: @dataset,
          num_pairs: 10,
          words: 'abstract background',
          window: 50)
        @grams = @result.cooccurrences
      end

      it 'returns a result object' do
        expect(@result).to be_a(RLetters::Analysis::Cooccurrence::Result)
        expect(@result.scoring).to eq(scoring)
      end

      it 'returns the correct number of grams' do
        expect(@grams.size).to eq(1)
      end

      it 'returns reasonable values for the weights' do
        @grams.each do |g|
          expect(g[1]).to be_a(Numeric)
          expect(g[1]).to be > 0 if g[1].is_a?(Integer)
          expect(g[1]).to be_finite if g[1].is_a?(Float)
        end
      end
    end

    describe 'stemming' do
      before(:example) do
        @result = described_class.call(
          scoring: scoring,
          dataset: @dataset,
          words: 'abstract',
          window: 50,
          stemming: :stem)
        @grams = @result.cooccurrences
      end

      it 'returns a result object' do
        expect(@result).to be_a(RLetters::Analysis::Cooccurrence::Result)
        expect(@result.scoring).to eq(scoring)
        expect(@result.stemming).to eq(:stem)
      end

      it 'returns stemmed grams' do
        expect(@grams).to satisfy { |l| l.find { |g| g.first == 'abstract ar' } }
      end
    end

    describe 'lemmatization' do
      before(:example) do
        @old_path = ENV['NLP_TOOL_PATH']
        ENV['NLP_TOOL_PATH'] = 'stubbed'

        expect(RLetters::Analysis::NLP).to receive(:lemmatize_words).with(['abstract']).and_return(['the'])
        allow(RLetters::Analysis::NLP).to receive(:lemmatize_words) { |array| array }

        @result = described_class.call(
          scoring: scoring,
          dataset: @dataset,
          num_pairs: 10,
          words: 'abstract',
          window: 50,
          stemming: :lemma)
        @grams = @result.cooccurrences
      end

      after(:example) do
        ENV['NLP_TOOL_PATH'] = @old_path
      end

      it 'returns a result object' do
        expect(@result).to be_a(RLetters::Analysis::Cooccurrence::Result)
        expect(@result.scoring).to eq(scoring)
      end

      it 'returns grams with the lemmatized words' do
        @grams.each do |g|
          expect(g.first).to start_with('the ')
        end
      end
    end

    context 'with a single uppercase word (regression test)' do
      it 'still works' do
        grams = described_class.call(
          scoring: scoring,
          dataset: @dataset,
          num_pairs: 10,
          words: 'ABSTRACT',
          window: 50)
        expect(grams.cooccurrences[0][0].split).to include('abstract')
      end
    end
  end
end
