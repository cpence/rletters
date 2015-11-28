require 'rails_helper'

RSpec.describe RLetters::VirtusExt::LowercaseString do
  class LowerStringTester
    include Virtus.model(strict: true)
    attribute :string, RLetters::VirtusExt::LowercaseString, required: true
  end

  describe '#coerce' do
    it 'leaves a lowercase string alone' do
      model = LowerStringTester.new(string: 'asdfghj')
      expect(model.string).to eq('asdfghj')
    end

    it 'lowercases a mixed-case string' do
      model = LowerStringTester.new(string: 'ÉstiÜdO')
      expect(model.string).to eq('éstiüdo')
    end

    it 'chokes on anything else' do
      expect {
        LowerStringTester.new(string: 37)
      }.to raise_error(ArgumentError)
    end
  end
end
