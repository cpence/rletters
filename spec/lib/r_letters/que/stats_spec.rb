require 'rails_helper'

RSpec.describe RLetters::Que::Stats do
  describe '.stats' do
    it 'includes all four keys' do
      @stats = RLetters::Que::Stats.stats

      expect(@stats[:total]).to be
      expect(@stats[:running]).to be
      expect(@stats[:failing]).to be
      expect(@stats[:scheduled]).to be
    end

    it 'responds to the existence of a job' do
      mock_que_job
      @stats = RLetters::Que::Stats.stats

      expect(@stats[:total]).to eq(1)
      expect(@stats[:running]).to eq(0)
      expect(@stats[:failing]).to eq(0)
      expect(@stats[:scheduled]).to eq(1)
    end
  end
end
