require 'rails_helper'

RSpec.describe RLetters::VirtusExt::SplitList do
  class SplitTester
    include Virtus.model(strict: true)
    attribute :list, RLetters::VirtusExt::SplitList, required: true
  end

  describe '#coerce' do
    it 'should pass along an array' do
      model = SplitTester.new(list: [1, 2, 3])
      expect(model.list).to match_array([1, 2, 3])
    end

    it 'should coerce a Documents::StopList' do
      stop_list = build(:stop_list)
      model = SplitTester.new(list: stop_list)

      expect(model.list).to match_array(['a', 'an', 'the'])
    end

    it 'should coerce a string to a space-separated list' do
      model = SplitTester.new(list: 'a an the')
      expect(model.list).to match_array(['a', 'an', 'the'])
    end

    it 'should choke on anything else' do
      expect {
        SplitTester.new(list: 37)
      }.to raise_error(ArgumentError)
    end
  end
end
