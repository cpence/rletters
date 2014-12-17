# -*- encoding : utf-8 -*-

RSpec.shared_examples_for 'a cooccurrence analyzer' do
  before(:each) do
    @user = create(:user)
    @dataset = create(:full_dataset, stub: true, english: true, user: @user)
  end

  describe 'single word analysis' do
    before(:each) do
      @grams = described_class.new(@dataset, 10, 'the', 6).call
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
  end

  describe 'multiple word analysis' do
    before(:each) do
      @grams = described_class.new(@dataset, 10, 'it, was, the', 6).call
    end

    it 'returns the correct number of grams' do
      expect(@grams.size).to eq(3)
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
    before(:each) do
      @grams = described_class.new(@dataset, 10, 'the', 6, :stem).call
    end

    it 'returns stemmed grams' do
      expect(@grams).to satisfy { |l| l.find { |g| g.first == 'the wa' } }
    end
  end

  describe 'lemmatization' do
    before(:each) do
      expect(RLetters::Analysis::NLP).to receive(:lemmatize_words).with(['the']).and_return(['was'])
      allow(RLetters::Analysis::NLP).to receive(:lemmatize_words) { |array| array }

      @grams = described_class.new(@dataset, 10, 'the', 6, :lemma).call
    end

    it 'returns grams with the lemmatized words' do
      @grams.each do |g|
        expect(g.first).to start_with('was ')
      end
    end
  end

  describe '.progress' do
    it 'calls progress less than and equal to 100' do
      called_sub_100 = false
      called_100 = false

      grams = described_class.new(@dataset, 10, 'the', 6, nil, ->(p) {
        if p < 100
          called_sub_100 = true
        else
          called_100 = true
        end
      }).call

      expect(called_sub_100).to be true
      expect(called_100).to be true
    end
  end

  context 'with a single uppercase word' do
    it 'still works' do
      grams = described_class.new(@dataset, 10, 'THE', 6).call
      expect(grams[0][0].split).to include('the')
    end
  end
end
