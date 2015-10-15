require 'rails_helper'

RSpec.describe RLetters::Analysis::CraigZeta do
  before(:example) do
    @user = create(:user)
    # N.B.: If you do 10-doc datasets here, all the words are in common, and
    # there's no zeta scores.
    @dataset_1 = create(:full_dataset, entries_count: 2, working: true,
                                       user: @user, name: 'First Dataset')
    @dataset_2 = create(:full_dataset, entries_count: 2, working: true,
                                       user: @user, name: 'Second Dataset')

    @called_sub_100 = false
    @called_100 = false

    @analyzer = described_class.call(
      dataset_1: @dataset_1,
      dataset_2: @dataset_2,
      progress: lambda do |p|
        if p < 100
          @called_sub_100 = true
        else
          @called_100 = true
        end
      end)
  end

  describe '#zeta_scores' do
    it 'sorts the zeta scores' do
      expect(@analyzer.zeta_scores.first[1]).to be > @analyzer.zeta_scores.reverse_each.first[1]
    end

    it 'returns scores between zero and 2' do
      @analyzer.zeta_scores.each do |(_, score)|
        expect(0..2).to include(score)
      end
    end
  end

  describe '#dataset_1_markers' do
    it 'picks words from the front of the zeta score list' do
      expect(@analyzer.zeta_scores.first[0]).to eq(@analyzer.dataset_1_markers.first)
    end

    it 'returns the same number of markers for both sets' do
      expect(@analyzer.dataset_1_markers.size).to eq(@analyzer.dataset_2_markers.size)
    end
  end

  describe '#dataset_2_markers' do
    it 'picks words from the back of the zeta score list' do
      expect(@analyzer.zeta_scores.reverse_each.first[0]).to eq(@analyzer.dataset_2_markers.first)
    end
  end

  describe '#graph_points' do
    it 'builds points the right way' do
      expect(@analyzer.graph_points[0].x).to be_a(Float)
      expect(@analyzer.graph_points[0].y).to be_a(Float)
      expect(@analyzer.graph_points[0].name).to be_a(String)
    end

    it 'puts graph points between 0 and 1' do
      @analyzer.graph_points.each do |p|
        expect(0..1).to include(p.x)
        expect(0..1).to include(p.y)
      end
    end

    it 'labels all the graph points with dataset names' do
      @analyzer.graph_points.each do |p|
        expect(p.name).to satisfy do |name|
          name.include?('First Dataset') || name.include?('Second Dataset')
        end
      end
    end
  end

  describe 'progress reporting' do
    it 'calls the progress function with under and equal to 100' do
      expect(@called_sub_100).to be true
      expect(@called_100).to be true
    end
  end
end
