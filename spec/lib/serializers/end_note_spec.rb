# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Serializers::EndNote do

  context 'when serializing a single document' do
    before(:each) do
      @doc = FactoryGirl.build(:full_document)
      @str = @doc.to_endnote
    end

    it 'creates good EndNote' do
      expect(@str).to be_start_with("%0 Journal Article\n")
      expect(@str).to include('%A Botero, Carlos A.')
      expect(@str).to include('%A Mudge, Andrew E.')
      expect(@str).to include('%A Koltz, Amanda M.')
      expect(@str).to include('%A Hochachka, Wesley M.')
      expect(@str).to include('%A Vehrencamp, Sandra L.')
      expect(@str).to include('%T How Reliable are the Methods for Estimating Repertoire Size?')
      expect(@str).to include('%J Ethology')
      expect(@str).to include('%V 114')
      expect(@str).to include('%P 1227-1238')
      expect(@str).to include('%M 10.1111/j.1439-0310.2008.01576.x')
      expect(@str).to include('%D 2008')
      # This extra carriage return is the item separator, and is thus very
      # important
      expect(@str).to be_end_with("\n\n")
    end
  end

  context 'when serializing an array of documents' do
    before(:each) do
      doc = FactoryGirl.build(:full_document)
      @docs = [doc, doc]
      @str = @docs.to_endnote
    end

    it 'creates good EndNote' do
      expect(@str).to be_start_with("%0 Journal Article\n")
      expect(@str).to include("\n\n%0 Journal Article\n")
    end
  end

end
