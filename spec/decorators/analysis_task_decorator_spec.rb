# -*- encoding : utf-8 -*-
require 'spec_helper'

RSpec.describe AnalysisTaskDecorator, type: :decorator do
  describe '#status_message' do
    it 'works with both percent and message' do
      task = double("Datasets::AnalysisTask",
                    status: OpenStruct.new(pct_complete: 30,
                                           message: "Going"))
      decorated = described_class.decorate(task)

      expect(decorated.status_message).to eq('30%: Going')
    end

    it 'works with only percent' do
      task = double("Datasets::AnalysisTask",
                    status: OpenStruct.new(pct_complete: 30))
      decorated = described_class.decorate(task)

      expect(decorated.status_message).to eq('30%')
    end

    it 'works with only message' do
      task = double("Datasets::AnalysisTask",
                    status: OpenStruct.new(message: "Going"))
      decorated = described_class.decorate(task)

      expect(decorated.status_message).to eq('Going')
    end
  end
end
