# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe Integer do
  describe '#factorial' do
    it 'gives the correct values for a few integers' do
      expect(4.factorial).to eq(24)
      expect(10.factorial).to eq(3628800)

      expect(0.factorial).to eq(1)
      expect(1.factorial).to eq(1)
      expect(2.factorial).to eq(2)
    end
  end
end
