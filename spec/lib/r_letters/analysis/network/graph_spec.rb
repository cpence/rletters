require 'spec_helper'

RSpec.describe RLetters::Analysis::Network::Graph do
  before(:context) do
    @user = create(:user)
    @dataset = create(:full_dataset, entries_count: 0, user: @user)
    @dataset.entries += [create(:entry, dataset: @dataset, uid: WORKING_UIDS[2])]
    @stop_list = create(:stop_list)
  end

  context 'without a focal word' do
    before(:context) do
      @called_sub_100 = false
      @called_100 = false

      @graph = described_class.new(@dataset, nil, [2, 5], 'en', lambda do |p|
        if p < 100
          @called_sub_100 = true
        else
          @called_100 = true
        end
      end)
    end

    it 'creates nodes and edges' do
      expect(@graph.nodes).not_to be_empty
      expect(@graph.edges).not_to be_empty
    end

    it 'connects nodes to stemmed words' do
      node = @graph.find_node(word: 'disease')
      expect(node).to be
      expect(node.id).to eq('diseas')
      expect(node.words).to include('disease')
    end

    it 'calls the progress reporter' do
      expect(@called_sub_100).to be true
      expect(@called_100).to be true
    end

    describe '#find_node' do
      before(:context) do
        @node = @graph.nodes.find { |n| n.words.include?('disease') }
      end

      it 'finds by id' do
        expect(@graph.find_node(id: 'diseas')).to eq(@node)
      end

      it 'finds by stem (same as id)' do
        expect(@graph.find_node(stem: 'diseas')).to eq(@node)
      end

      it 'finds by word' do
        expect(@graph.find_node(word: 'disease')).to eq(@node)
      end

      it 'throws an error when no find options are specified' do
        expect {
          @graph.find_node(nothing: 'doing')
        }.to raise_error(ArgumentError)
      end
    end

    describe '#find_edge' do
      before(:context) do
        @node_1 = @graph.find_node(word: 'disease')
        @node_2 = @graph.find_node(word: 'blood')
      end

      it 'finds both ways' do
        e_1 = @graph.find_edge(@node_1.id, @node_2.id)
        e_2 = @graph.find_edge(@node_2.id, @node_1.id)

        expect(e_1).to be
        expect(e_2).to be
        expect(e_1).to eq(e_2)
      end
    end

    describe('#max_edge_weight') do
      it 'is an integer' do
        expect(@graph.max_edge_weight).to be_an(Integer)
        expect(@graph.max_edge_weight).to be > 1
      end
    end
  end

  context 'with a focal word' do
    before(:context) do
      @graph = described_class.new(@dataset, 'disease')

      @connectivity = {}

      @graph.nodes.each do |n|
        @connectivity[n.id] = @graph.edges.inject(0) do |sum, edge|
          sum + ((edge.one == n.id || edge.two == n.id) ? 1 : 0)
        end
      end

      @max_connectivity = @connectivity.values.max
    end

    it 'gives highest connectivity to the central word' do
      expect(@connectivity[@graph.find_node(word: 'disease').id]).to eq(@max_connectivity)
    end
  end

  context 'with a different language' do
    before(:context) do
      create(:stop_list, language: 'de', list: 'es die der das')
      @graph = described_class.new(@dataset, nil, [2, 5], 'de')
    end

    it 'includes words on the English stop list' do
      elt = @graph.nodes.find do |n|
        n.words.include?('the')
      end
      expect(elt).to be
    end
  end
end
