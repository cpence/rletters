# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Array do

  describe '#with_indifferent_access' do
    context 'with an array without hashes' do
      it "doesn't convert anything" do
        arr = [1, 2, 3, 4]
        arr2 = arr.with_indifferent_access

        arr.should eq(arr2)
      end
    end

    context 'with an array with hashes' do
      it "converts the hashes" do
        arr = [ 1, 3, { 'test' => 'test2' }, [ 2, 4, 6, { 'test3' => 'test4' } ] ]
        arr2 = arr.with_indifferent_access

        arr2[2][:test].should eq('test2')
        arr2[3][3][:test3].should eq('test4')
      end
    end
  end

end

describe Object do

  describe '#with_indifferent_access' do
    context 'when self is not duplicable' do
      it "calls successfully but doesn't change anything" do
        1.with_indifferent_access.should eq(1)
      end
    end

    context 'when self is duplicable' do
      it "calls successfully but doesn't change anything" do
        'asdf'.with_indifferent_access.should eq('asdf')
      end
    end
  end

end
