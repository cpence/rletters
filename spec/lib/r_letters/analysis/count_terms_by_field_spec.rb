# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe RLetters::Analysis::CountTermsByField do
  describe '#counts_for' do
    context 'without a dataset' do
      before(:context) do
        @called_sub_100 = false
        @called_100 = false

        counter = described_class.new('violence', nil, ->(p) {
          if p < 100
            @called_sub_100 = true
          else
            @called_100 = true
          end
        })
        @counts = counter.counts_for(:year)
      end

      it 'gets the values for the whole corpus' do
        expect(@counts['2009']).to eq(4)
        expect(@counts['2008']).to eq(1)
      end

      it 'gets different counts than the article counts' do
        article_counts = RLetters::Analysis::CountArticlesByField.new.counts_for(:year)
        expect(@counts['2009']).not_to eq(article_counts['2009'])
        expect(@counts['2007']).not_to eq(article_counts['2007'])
        expect(@counts['2010']).not_to eq(article_counts['2010'])
      end

      it 'calls the progress function with under and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end

    context 'without a dataset, with Solr failure' do
      it 'is empty' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(described_class.new('malaria').counts_for(:year)).to eq({})
      end
    end

    context 'with a dataset' do
      before(:context) do
        @user = create(:user)
        @dataset = create(:full_dataset, entries_count: 2, working: true,
                                         user: @user)
        @counts = described_class.new('disease', @dataset).counts_for(:year)

        @called_sub_100 = false
        @called_100 = false

        counter = described_class.new('disease', @dataset, ->(p) {
          if p < 100
            @called_sub_100 = true
          else
            @called_100 = true
          end
        })
        @counts = counter.counts_for(:year)
      end

      it 'gets the values for the dataset' do
        expect(@counts.size).to eq(1)
        expect(@counts['2009']).to be > 0
      end

      it 'calls the progress function with under and equal to 100' do
        expect(@called_sub_100).to be true
        expect(@called_100).to be true
      end
    end

    context 'without a dataset, with Solr failure' do
      it 'is empty' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(described_class.new('disease', @dataset).counts_for(:year)).to eq({})
      end
    end
  end
end
