
RSpec.shared_examples_for 'a collocation analyzer' do |scoring|
  before(:example) do
    @user = create(:user)
    @dataset = create(:full_dataset, working: true)
  end

  context 'without a focal word' do
    before(:example) do
      @called_sub_100 = false
      @called_100 = false

      @result = described_class.call(
        scoring: scoring,
        dataset: @dataset,
        num_pairs: 10,
        progress: lambda do |p|
          if p < 100
            @called_sub_100 = true
          else
            @called_100 = true
          end
        end)
    end

    it 'returns a result object' do
      expect(@result).to be_a(RLetters::Analysis::Collocation::Result)
    end

    it 'sets scoring correctly' do
      expect(@result.scoring).to eq(scoring)
    end

    it 'returns the correct number of grams' do
      expect(@result.collocations.size).to eq(10)
    end

    it 'returns reasonable values for the weights' do
      @result.collocations.each do |g|
        expect(g[1]).to be_a(Numeric)
        expect(g[1]).to be > 0 if g[1].is_a?(Integer)
        expect(g[1]).to be_finite if g[1].is_a?(Float)
      end
    end

    describe '.progress' do
      it 'calls progress less than and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end
  end

  context 'with a focal word' do
    before(:example) do
      @result = described_class.call(
        scoring: scoring,
        dataset: @dataset,
        num_pairs: 10,
        focal_word: 'present')
    end

    it 'returns a result object' do
      expect(@result).to be_a(RLetters::Analysis::Collocation::Result)
    end

    it 'sets scoring correctly' do
      expect(@result.scoring).to eq(scoring)
    end

    it 'returns some grams' do
      expect(@result.collocations.size).to be >= 1
    end

    it 'only returns grams containing the focal word' do
      @result.collocations.each do |g|
        expect(g[0].split).to include('present')
      end
    end

    it 'returns reasonable values for the weights' do
      @result.collocations.each do |g|
        expect(g[1]).to be_a(Numeric)
        expect(g[1]).to be > 0 if g[1].is_a?(Integer)
        expect(g[1]).to be_finite if g[1].is_a?(Float)
      end
    end
  end

  context 'with an uppercase focal word' do
    it 'still works' do
      result = described_class.call(
        scoring: scoring,
        dataset: @dataset,
        num_pairs: 10,
        focal_word: 'PRESENT')
      expect(result.collocations[0][0].split).to include('present')
    end
  end
end
