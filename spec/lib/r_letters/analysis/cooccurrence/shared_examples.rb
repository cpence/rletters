# -*- encoding : utf-8 -*-

RSpec.shared_examples_for 'a cooccurrence analyzer' do
  before(:context) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 10, working: true,
                                     user: @user)
    @grams = described_class.new(@dataset, 10, 'the').call
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

  describe '.progress' do
    it 'calls progress less than and equal to 100' do
      called_sub_100 = false
      called_100 = false

      grams = described_class.new(@dataset, 10, 'the', 250, nil, ->(p) {
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

  context 'with an uppercase word' do
    it 'still works' do
      grams = described_class.new(@dataset, 10, 'THE').call
      expect(grams[0][0].split).to include('the')
    end
  end
end
