require 'spec_helper'

RSpec.describe String do
  describe '#html_id' do
    it 'sanitizes illegal characters' do
      expect('a$#%/_=-+32'.html_id).to eq('a______-_32')
    end

    it 'prepends alpha if required' do
      expect('1234'.html_id).to eq('a1234')
    end
  end

  describe '#html_id!' do
    it 'sanitizes illegal characters' do
      s = 'a$#%/_=-+32'
      s.html_id!

      expect(s).to eq('a______-_32')
    end

    it 'prepends alpha if required' do
      s = '1234'
      s.html_id!

      expect(s).to eq('a1234')
    end
  end
end
