require 'rails_helper'

RSpec.describe RLetters::VirtusExt::StopList do
  class StopTester
    include Virtus.model(strict: true)
    attribute :list, RLetters::VirtusExt::StopList, required: true
  end

  describe '#coerce' do
    it 'passes through a Documents::StopList' do
      stop_list = build(:stop_list)
      model = StopTester.new(list: stop_list)

      expect(model.list).to match_array(['a', 'an', 'the'])
    end

    it 'loads the matching list if there is one' do
      stop_list = create(:stop_list)
      model = StopTester.new(list: 'en')
      expect(model.list).to match_array(['a', 'an', 'the'])
    end

    it 'loads a string to a space-separated list if there is none' do
      model = StopTester.new(list: 'a an the')
      expect(model.list).to match_array(['a', 'an', 'the'])
    end

    it 'chokes on anything else' do
      expect {
        StopTester.new(list: 37)
      }.to raise_error(ArgumentError)
    end
  end
end
