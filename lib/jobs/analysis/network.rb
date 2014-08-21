# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Examine the network of words associated with a focal term
    class Network < Jobs::Analysis::Base
      add_concern 'ComputeWordFrequencies'

      # Examine the network of words associated with a focal term.
      #
      # @param [Hash] options parameters for this job
      # @option options [String] :user_id the user whose dataset we are to
      #   work on
      # @option options [String] :dataset_id the dataset to operate on
      # @option options [String] :task_id the analysis task we're working from
      # @option options [String] :word the focal word to analyze
      # @return [void]
      # @example Start a job for examining a word network
      #   Jobs::Analysis::Collocation.create(user_id: current_user.to_param,
      #                                      dataset_id: dataset.to_param,
      #                                      task_id: task.to_param,
      #                                      word: 'test')
      def perform
        at(0, 1, t('common.progress_initializing'))
        standard_options!

        # Fetch the focal word
        word = options[:word].mb_chars.downcase.to_s
        fail ArgumentError, 'Focal word not specified' unless options[:word]

        graph = RLetters::Analysis::Network::Graph.new(
          @dataset,
          options[:word],
          [2, 5],
          'en',
          ->(p) { at(p, 100, t('.progress_network')) }
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
        at(100, 100, t('common.progress_finished'))
        data = {
          name: @dataset.name,
          word: word,
          d3_nodes: d3_nodes,
          d3_links: d3_links
        }

        # Write it out
        ios = StringIO.new(data.to_json)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'network.json'
        file.content_type = 'application/json'

        @task.result = file

        # We're done here
        @task.finish!

        completed
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end
    end
  end
end
