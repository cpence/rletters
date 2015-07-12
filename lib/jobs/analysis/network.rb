
module Jobs
  module Analysis
    # Examine the network of words associated with a focal term
    class Network < Jobs::Analysis::Base
      add_concern 'ComputeWordFrequencies'

      # Examine the network of words associated with a focal term.
      #
      # @param [String] user_id the user whose dataset we are to work on
      # @param [String] dataset_id the dataset to operate on
      # @param [String] task_id the task we're working from
      # @param [Hash] options parameters for this job
      # @option options [String] :word the focal word to analyze
      # @return [void]
      def self.perform(user_id, dataset_id, task_id, options)
        standard_options(user_id, dataset_id, task_id)

        # Fetch the focal word
        options.symbolize_keys!
        fail ArgumentError, 'Focal word not specified' unless options[:word]
        word = options[:word].mb_chars.downcase.to_s

        graph = RLetters::Analysis::Network::Graph.new(
          get_dataset(task_id),
          options[:word],
          [2, 5],
          'en',
          ->(p) { get_task(task_id).at(p, 100, t('.progress_network')) }
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
          name: get_dataset(task_id).name,
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

        task = get_task(task_id)
        task.result = file
        task.mark_completed
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end
    end
  end
end
