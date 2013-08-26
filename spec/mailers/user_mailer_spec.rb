require "spec_helper"

describe UserMailer do
  describe '#job_finished_email' do
    before(:each) do
      @user = mock_model(User, email: 'user@user.com')
      @dataset = mock_model(Dataset, user: @user, id: '1', name: 'The Dataset')
      @task = mock_model(AnalysisTask, dataset: @dataset, name: 'The Text Analysis')

      @mail = UserMailer.job_finished_email(@user, @task)
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
      expect(@mail.body.encoded).to match('The Text Analysis')
    end

    it 'mentions the dataset name' do
      expect(@mail.body.encoded).to match('The Dataset')
    end

    it 'includes the link to the dataset' do
      expect(@mail.body.encoded).to match(dataset_url(@dataset))
    end
  end
end
