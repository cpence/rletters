# -*- encoding : utf-8 -*-
require 'spec_helper'

describe RLetters::Analysis::CountTermsByField do
  describe '#counts_for' do
    context 'without a dataset' do
      before(:each) do
        @counts = described_class.new('blackwell').counts_for(:year)
      end

      it 'gets the values for the whole corpus' do
        expect(@counts['2009']).to eq(10)
        expect(@counts['2007']).to eq(55)
      end

      it 'gets different counts than the article counts' do
        article_counts = RLetters::Analysis::CountArticlesByField.new.counts_for(:year)
        expect(@counts['2009']).not_to eq(article_counts['2009'])
        expect(@counts['2007']).not_to eq(article_counts['2007'])
        expect(@counts['2010']).not_to eq(article_counts['2010'])
      end

      it 'calls the progress function with under and equal to 100' do
        called_sub_100 = false
        called_100 = false

        counter = described_class.new('blackwell', nil, ->(p) {
          if p < 100
            called_sub_100 = true
          else
            called_100 = true
          end
        })
        counter.counts_for(:year)

        expect(called_sub_100).to be true
        expect(called_100).to be true
      end
    end

    context 'without a dataset, with Solr failure' do
      it 'is empty' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(described_class.new('blackwell').counts_for(:year)).to eq({})
      end
    end

    context 'with a dataset' do
      before(:each) do
        @user = create(:user)
        @dataset = create(:full_dataset, entries_count: 10, working: true,
                                         user: @user)
        @counts = described_class.new('blackwell', @dataset).counts_for(:year)
      end

      it 'gets the values for the dataset' do
        expect(@counts.size).to eq(9)
        expect(@counts['2003']).to eq(1)
      end

      it 'calls the progress function with under and equal to 100' do
        called_sub_100 = false
        called_100 = false

        counter = described_class.new('blackwell', @dataset, ->(p) {
          if p < 100
            called_sub_100 = true
          else
            called_100 = true
          end
        })
        counter.counts_for(:year)

        expect(called_sub_100).to be true
        expect(called_100).to be true
      end
    end

    context 'without a dataset, with Solr failure' do
      it 'is empty' do
        stub_request(:any, /(127\.0\.0\.1|localhost)/).to_timeout
        expect(described_class.new('blackwell', @dataset).counts_for(:year)).to eq({})
      end
    end
  end
end
