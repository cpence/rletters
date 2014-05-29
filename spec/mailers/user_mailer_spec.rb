# -*- encoding : utf-8 -*-
require 'spec_helper'

describe UserMailer do
  describe '#job_finished_email' do
    before(:each) do
      @task = create(:analysis_task)

      @mail = UserMailer.job_finished_email('user@user.com', @task.to_param)
    end

    it 'sets the correct subject' do
      expect(@mail.subject).to eq('RLetters analysis job completed')
    end

    it 'sets the from e-mail' do
      expect(@mail.from).to eq(['not@an.email.com'])
    end

    it 'sets the to e-mail' do
      expect(@mail.to).to eq(['user@user.com'])
    end

    it 'mentions the analysis task name' do
      expect(@mail.body.encoded).to match(@task.name)
    end

    it 'mentions the dataset name' do
      expect(@mail.body.encoded).to match(@task.dataset.name)
    end

    it 'includes the link to the fetch page' do
      expect(@mail.body.encoded).to match(workflow_fetch_url)
    end
  end
end
