# frozen_string_literal: true

xml.instruct!
data = JSON.parse(task.json)
nodes = data['d3_nodes']
xml.graphml('xmlns' => 'http://graphml.graphdrawing.org/xmlns',
            'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
            'xsi:schemaLocation' => 'http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd') do

  xml.key('id' => 'd0', 'for' => 'edge', 'attr.name' => 'weight',
          'attr.type' => 'double')
  xml.key('id' => 'd1', 'for' => 'node', 'attr.name' => 'label',
          'attr.type' => 'string')
  xml.key('id' => 'd2', 'for' => 'node', 'attr.name' => 'forms',
          'attr.type' => 'string')

  xml.graph('id' => 'g', 'edgedefault' => 'undirected') do
    nodes.each_with_index do |n, idx|
      xml.node('id' => "n#{idx}") do
        xml.data(n['name'], 'key' => 'd1')
        xml.data(n['forms'].join(' '), 'key' => 'd2')
      end
    end
    data['d3_links'].each do |l|
      xml.edge('source' => "n#{l['source']}",
               'target' => "n#{l['target']}") do
        xml.data(l['strength'], 'key' => 'd0')
      end
    end
  end
end
