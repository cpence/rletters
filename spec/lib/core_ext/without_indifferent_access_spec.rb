# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Hash do
  
  describe '#without_indifferent_access' do
    context 'with hashes as hash keys' do
      it 'converts successfully' do
        hash = { 'test' => { 'test2' => 'test3' }.with_indifferent_access }.with_indifferent_access
        hash2 = hash.without_indifferent_access
      
        hash2[:test].should eq(nil)
        hash2['test'][:test2].should eq(nil)
        hash2['test']['test2'].should eq('test3')        
      end
    end
    
    context 'without hashes as hash keys' do
      it 'converts successfully' do
        hash = { 'test' => 'test2' }.with_indifferent_access
        hash2 = hash.without_indifferent_access
        
        hash2[:test].should eq(nil)
        hash2['test'].should eq('test2')
      end
    end
  end
  
end

describe Array do
  
  describe '#without_indifferent_access' do
    context 'with no hashes' do
      it 'should leave the array alone' do
        arr = [ 1, 3, 5 ]
        arr2 = arr.without_indifferent_access
        
        arr2.should eq(arr)
      end
    end
    
    context 'with non-indifferent hashes' do
      it 'should leave the hashes alone' do
        arr = [ 1, 3, { 'test' => 'test2' } ]
        arr2 = arr.without_indifferent_access
        
        arr2[2].should eq({ 'test' => 'test2' })
        arr2[2].class.should eq(Hash)
      end
    end
    
    context 'with indifferent hashes' do
      it 'should convert them to regular Hashes' do
        arr = [ 1, 3, { 'test' => 'test2' }.with_indifferent_access ]
        arr2 = arr.without_indifferent_access
        
        arr2[2].should eq({ 'test' => 'test2' })
        arr2[2][:test].should eq(nil)
        arr2[2].class.should eq(Hash)
      end
    end
  end
  
end
