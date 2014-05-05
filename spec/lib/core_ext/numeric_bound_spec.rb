# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Numeric do
  describe '#lbound' do
    it 'works' do
      expect(-3.lbound(0)).to eq(0)
      expect(0.lbound(0)).to eq(0)
      expect(10.lbound(0)).to eq(10)
    end
  end

  describe '#ubound' do
    it 'works' do
      expect(30.ubound(10)).to eq(10)
      expect(10.ubound(10)).to eq(10)
      expect(5.ubound(10)).to eq(5)
    end
  end

  describe '#bound' do
    it 'works' do
      expect(1.bound(5, 10)).to eq(5)
      expect(5.bound(5, 10)).to eq(5)
      expect(7.bound(5, 10)).to eq(7)
      expect(10.bound(5, 10)).to eq(10)
      expect(50.bound(5, 10)).to eq(10)
    end
  end
end
