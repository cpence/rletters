require 'rails_helper'

RSpec.describe Admin::QueJob do
  describe '.scheduled' do
    it 'works' do
      mock_que_job(1)
      mock_que_job(2, true)
      mock_que_job(3, true)
      mock_que_job(4)

      arr = Admin::QueJob.scheduled

      expect(arr.size).to eq(2)
      expect(arr.map { |j| j.job_id }).to match_array([1, 4])
    end
  end

  describe '.failing' do
    it 'works' do
      mock_que_job(1)
      mock_que_job(2, true)
      mock_que_job(3, true)
      mock_que_job(4)

      arr = Admin::QueJob.failing

      expect(arr.size).to eq(2)
      expect(arr.map { |j| j.job_id }).to match_array([2, 3])
    end
  end

  describe '.get' do
    it 'works' do
      mock_que_job(1)
      j = Admin::QueJob.find_by!(job_id: 1)

      expect(j.job_id).to be
      expect(j.args).to be
    end
  end

  describe '.delete' do
    it 'works' do
      mock_que_job(1)
      expect {
        Admin::QueJob.delete_all(job_id: 1)
      }.to change { RLetters::Que::Stats.stats[:scheduled] }.by(-1)
    end
  end

  describe '.reschedule' do
    it 'works' do
      mock_que_job(1)
      expect {
        Admin::QueJob.where(job_id: 1).update_all(run_at: 3.days.ago)
      }.to change { Admin::QueJob.find_by!(job_id: 1).run_at }
    end
  end
end
