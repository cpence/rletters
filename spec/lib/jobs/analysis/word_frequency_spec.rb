# -*- encoding : utf-8 -*-
require 'spec_helper'

describe Jobs::Analysis::WordFrequency,
         vcr: { cassette_name: 'solr_single_fulltext' } do

  it_should_behave_like 'an analysis job'

  before(:each) do
    @user = FactoryGirl.create(:user)
    @dataset = FactoryGirl.create(:full_dataset, entries_count: 10,
                                  working: true, user: @user)
  end

  after(:each) do
    @dataset.analysis_tasks[0].destroy unless @dataset.analysis_tasks[0].nil?
  end

  describe '#perform' do
    it 'accepts all the various valid parameters' do
      params_to_test =
        [{ user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          block_size: '100',
          split_across: 'true',
          num_words: '0' },
        { user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          block_size: '100',
          split_across: 'false',
          num_words: '0' },
        { user_id: @user.to_param,
          dataset_id: @dataset.to_param,
          num_blocks: '10',
          split_across: 'true',
          num_words: '0' }]

      expect {
        # Make sure to rewind the VCR cassette each time we do this
        VCR.eject_cassette

        params_to_test.each do |params|
          VCR.use_cassette 'solr_single_fulltext' do
            Jobs::Analysis::WordFrequency.new(params).perform
          end
        end
      }.to_not raise_error
    end

    context 'when all parameters are valid' do
      before(:each) do
        Jobs::Analysis::WordFrequency.new(user_id: @user.to_param,
                                          dataset_id: @dataset.to_param,
                                          block_size: '100',
                                          split_across: 'true',
                                          num_words: '0').perform

        @output = CSV.read(@dataset.analysis_tasks[0].result_file.filename)
      end

      it 'names the task correctly' do
        expect(@dataset.analysis_tasks[0].name).to eq('Word frequency list')
      end

      it 'creates good CSV' do
        expect(@output).to be_an(Array)
      end
    end
  end
end

