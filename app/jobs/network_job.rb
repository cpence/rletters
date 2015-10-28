
# Examine the network of words associated with a focal term
class NetworkJob < BaseJob
  # Examine the network of words associated with a focal term.
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options parameters for this job
  # @option options [String] :word the focal word to analyze
  # @return [void]
  def perform(task, options)
    standard_options(task, options)

    graph = RLetters::Analysis::Network::Graph.new(
      dataset: dataset,
      focal_word: options.fetch(:word),
      progress: ->(p) { task.at(p, 100, t('.progress_network')) }
    )

    # Convert to D3-able format
    d3_nodes = graph.nodes.map do |n|
      { name: n.id,
        forms: n.words }
    end

    max_weight = graph.max_edge_weight.to_f
    d3_links = graph.edges.map do |e|
      { source: d3_nodes.find_index { |n| e.one == n[:name] },
        target: d3_nodes.find_index { |n| e.two == n[:name] },
        strength: e.weight.to_f / max_weight }
    end

    # Save out all the data
    data = {
      name: dataset.name,
      word: options[:word],
      d3_nodes: d3_nodes,
      d3_links: d3_links,
      word_stem: t('.word_stem'),
      word_forms: t('.word_forms')
    }

    # Write it out
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(data.to_json, filename: 'network.json',
                                  content_type: 'application/json')
    end
    task.mark_completed
  end
end
