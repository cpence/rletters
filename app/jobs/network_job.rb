
# Examine the network of words associated with a focal term
class NetworkJob < BaseJob
  include ComputeWordFrequencies

  # Examine the network of words associated with a focal term.
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options parameters for this job
  # @option options [String] :word the focal word to analyze
  # @return [void]
  def perform(task, options)
    standard_options(task)

    # Fetch the focal word
    options = options.with_indifferent_access
    fail ArgumentError, 'Focal word not specified' unless options[:word]
    word = options[:word].mb_chars.downcase.to_s

    graph = RLetters::Analysis::Network::Graph.new(
      dataset,
      options[:word],
      [2, 5],
      'en',
      ->(p) { task.at(p, 100, t('.progress_network')) }
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
      word: word,
      d3_nodes: d3_nodes,
      d3_links: d3_links,
      word_stem: t('.word_stem'),
      word_forms: t('.word_forms')
    }

    # Write it out
    ios = StringIO.new(data.to_json)
    file = Paperclip.io_adapters.for(ios)
    file.original_filename = 'network.json'
    file.content_type = 'application/json'

    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON',
                      result: file)
    task.mark_completed
  end

  # We don't want users to download the JSON file
  def self.download?
    false
  end
end
