require 'test_helper'

class RLetters::Analysis::Network::GraphTest < ActiveSupport::TestCase
  setup do
    create(:stop_list)
    @dataset = create(:dataset)
    create(:query, dataset: @dataset, q: "uid:\"#{WORKING_UIDS[2]}\"")
  end

  test 'no focal word, creates nodes and edges' do
    graph = RLetters::Analysis::Network::Graph.new(dataset: @dataset)

    refute_empty graph.nodes
    refute_empty graph.edges
  end

  test 'no focal word, connects nodes to stemmed words' do
    graph = RLetters::Analysis::Network::Graph.new(dataset: @dataset)

    node = graph.find_node(word: 'disease')
    refute_nil node

    assert_equal 'diseas', node.id
    assert_includes node.words, 'disease'
  end

  test 'progress reporting works' do
    called_sub_100 = false
    called_100 = false

    graph = RLetters::Analysis::Network::Graph.new(
      dataset: @dataset,
      progress: lambda do |p|
        if p < 100
          called_sub_100 = true
        else
          called_100 = true
        end
      end)

    assert called_sub_100
    assert called_100
  end

  test 'find_node works for various search types' do
    graph = RLetters::Analysis::Network::Graph.new(dataset: @dataset)

    node = graph.nodes.find { |n| n.words.include?('disease') }
    refute_nil node

    assert_equal node, graph.find_node(id: 'diseas')
    assert_equal node, graph.find_node(stem: 'diseas')
    assert_equal node, graph.find_node(word: 'disease')
  end

  test 'find_node throws when no find options are specified' do
    graph = RLetters::Analysis::Network::Graph.new(dataset: @dataset)

    assert_raises(ArgumentError) do
      graph.find_node(nothing: 'doing')
    end
  end

  test 'find_edge finds both ways' do
    graph = RLetters::Analysis::Network::Graph.new(dataset: @dataset)
    node_1 = graph.find_node(word: 'disease')
    node_2 = graph.find_node(word: 'blood')

    e_1 = graph.find_edge(node_1.id, node_2.id)
    e_2 = graph.find_edge(node_2.id, node_1.id)

    refute_nil e_1
    refute_nil e_2
    assert_equal e_1, e_2
  end

  test 'max_edge_weight works' do
    graph = RLetters::Analysis::Network::Graph.new(dataset: @dataset)

    assert_kind_of Integer, graph.max_edge_weight
    assert graph.max_edge_weight > 1
  end

  test 'with focal word, focal word has highest connectivity' do
    graph = RLetters::Analysis::Network::Graph.new(dataset: @dataset,
                                                   focal_word: 'disease')
    connectivity = {}

    graph.nodes.each do |n|
      connectivity[n.id] = graph.edges.inject(0) do |sum, edge|
        sum + ((edge.one == n.id || edge.two == n.id) ? 1 : 0)
      end
    end

    max_connectivity = connectivity.max { |a, b| a[1] <=> b[1] }

    assert_equal max_connectivity[0], 'diseas'
  end

  test 'with different language, uses correct stop list' do
    create(:stop_list, language: 'de', list: 'der die das')
    graph = RLetters::Analysis::Network::Graph.new(dataset: @dataset,
                                                   language: 'de')

    refute_nil graph.find_node(word: 'the')
  end
end
