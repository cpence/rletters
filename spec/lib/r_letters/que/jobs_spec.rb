require 'rails_helper'

RSpec.describe RLetters::Que::Jobs do
  describe '.scheduled' do
    it 'works' do
      mock_que_job(1)
      mock_que_job(2, true)
      mock_que_job(3, true)
      mock_que_job(4)

      arr = RLetters::Que::Jobs.scheduled

      expect(arr.size).to eq(2)
      expect(arr.map { |h| h[:job_id] }).to match_array([1, 4])
    end
  end

  describe '.failing' do
    it 'works' do
      mock_que_job(1)
      mock_que_job(2, true)
      mock_que_job(3, true)
      mock_que_job(4)

      arr = RLetters::Que::Jobs.failing

      expect(arr.size).to eq(2)
      expect(arr.map { |h| h[:job_id] }).to match_array([2, 3])
    end
  end

  describe '.get' do
    it 'works' do
      mock_que_job(1)
      hash = RLetters::Que::Jobs.get(1)

      expect(hash[:job_id]).to be
      expect(hash[:args]).to be
    end
  end

  describe '.delete' do
    it 'works' do
      mock_que_job(1)
      expect {
        RLetters::Que::Jobs.delete(1)
      }.to change { RLetters::Que::Stats.stats[:scheduled] }.by(-1)
    end
  end

  describe '.reschedule' do
    it 'works' do
      mock_que_job(1)
      expect {
        RLetters::Que::Jobs.reschedule(1, 3.days.ago)
      }.to change { RLetters::Que::Jobs.get(1)[:run_at] }
    end
  end
end
