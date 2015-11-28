require 'rails_helper'

RSpec.describe RLetters::VirtusExt::ParameterHash do
  class ParamHashTester
    include Virtus.model(strict: true)
    include RLetters::VirtusExt::ParameterHash

    attribute :string, String
  end

  describe '#parameter_hash' do
    it 'saves the base values' do
      model = ParamHashTester.new(string: 'test')
      expect(model.string).to eq('test')
      expect(model.parameter_hash[:string]).to eq('test')
    end

    it 'saves the uncoerced values' do
      model = ParamHashTester.new(string: 37)
      expect(model.string).to eq('37')
      expect(model.parameter_hash[:string]).to eq(37)
    end

    it 'saves unused parameters' do
      model = ParamHashTester.new(string: 'test', other: 37)
      expect(model.parameter_hash[:other]).to eq(37)
    end
  end
end
