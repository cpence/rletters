# -*- encoding : utf-8 -*-

RSpec.shared_examples_for 'a cooccurrence analyzer' do
  before(:context) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 2,
                      working: true, user: @user)
  end

  describe 'single word analysis' do
    before(:context) do
      @called_sub_100 = false
      @called_100 = false

      @grams = described_class.new(@dataset, 10, 'abstract', 6, nil, ->(p) {
        if p < 100
          @called_sub_100 = true
        else
          @called_100 = true
        end
      }).call
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
    before(:context) do
      @grams = described_class.new(@dataset, 10, 'disease, abstract', 6).call
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
    before(:context) do
      @grams = described_class.new(@dataset, 9999, 'abstract', 6, :stem).call
    end

    it 'returns stemmed grams' do
      expect(@grams).to satisfy { |l| l.find { |g| g.first == 'abstract ar' } }
    end
  end

  describe 'lemmatization' do
    before(:example) do
      @old_path = Admin::Setting.nlp_tool_path
      Admin::Setting.nlp_tool_path = 'stubbed'

      expect(RLetters::Analysis::NLP).to receive(:lemmatize_words).with(['abstract']).and_return(['the'])
      allow(RLetters::Analysis::NLP).to receive(:lemmatize_words) { |array| array }

      @grams = described_class.new(@dataset, 10, 'abstract', 6, :lemma).call
    end

    after(:example) do
      Admin::Setting.nlp_tool_path = @old_path
    end

    it 'returns grams with the lemmatized words' do
      @grams.each do |g|
        expect(g.first).to start_with('the ')
      end
    end
  end

  context 'with a single uppercase word' do
    it 'still works' do
      grams = described_class.new(@dataset, 10, 'ABSTRACT', 6).call
      expect(grams[0][0].split).to include('abstract')
    end
  end
end
