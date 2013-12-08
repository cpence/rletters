# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Examine the network of words associated with a focal term
    class Network < Jobs::Analysis::Base
      add_concern 'ComputeWordFrequencies'
      @queue = 'analysis'

      # Returns true if this job can be started now
      #
      # @return [Boolean] true
      def self.available?
        true
      end

      # Return how many datasets this job requires
      #
      # @return [Integer] number of datasets needed to perform this job
      def self.num_datasets
        1
      end

      # Examine the network of words associated with a focal term.
      #
      # @param [Hash] args parameters for this job
      # @option args [String] user_id the user whose dataset we are to work on
      # @option args [String] dataset_id the dataset to operate on
      # @option args [String] task_id the analysis task we're working from
      # @option args [String] word the focal word to analyze
      # @return [undefined]
      # @example Start a job for examining a word network
      #   Resque.enqueue(Jobs::Analysis::Collocation,
      #                  user_id: current_user.to_param,
      #                  dataset_id: dataset.to_param,
      #                  task_id: task.to_param,
      #                  word: 'test')
      def self.perform(args = {})
        args.symbolize_keys!
        args.remove_blank!

        user = User.find(args[:user_id])
        dataset = user.datasets.active.find(args[:dataset_id])
        task = dataset.analysis_tasks.find(args[:task_id])

        task.name = t('.short_desc')
        task.save

        # Fetch the focal word
        word = args[:word]
        fail ArgumentError, 'Focal word not specified' unless word
        word_stem = word.stem

        # Get the stop word list
        stop_words = Documents::StopList.find_by!(language: 'en').list.split

        # Create a list of lowercase words
        words = dataset.entries.map do |e|
          doc = Document.find(e.uid, fulltext: true)
          doc.fulltext.gsub(/[^A-Za-z ]/, '').downcase.split
        end

        # Remove stop words and stem
        words = words.flatten - stop_words
        words_stem = words.map { |w| w.stem }

        # Storage for the graph
        nodes = []
        forms = {}
        edges = []

        # Scan with two-word gap
        words.each_cons(2).each_with_index do |gap, i|
          gap_stem = words_stem[i, 2]
          next unless gap_stem.include? word_stem

          w_1 = nodes.find_index(gap_stem[0])
          if w_1.nil?
            nodes << gap_stem[0]
            w_1 = nodes.size - 1
          end

          forms[gap_stem[0]] ||= []
          forms[gap_stem[0]] << gap[0]

          w_2 = nodes.find_index(gap_stem[1])
          if w_2.nil?
            nodes << gap_stem[1]
            w_2 = nodes.size - 1
          end

          forms[gap_stem[1]] ||= []
          forms[gap_stem[1]] << gap[1]

          edge = edges.find { |e| e[0] == w_1 && e[1] == w_2 }
          if edge
            edge[2] += 1
          else
            edges << [w_1, w_2, 1]
          end
        end

        # Scan with five-word gap
        words.each_cons(5).each_with_index do |gap, i|
          gap_stem = words_stem[i, 5]
          next unless gap_stem.include? word_stem

          # Now pairwise through the gap
          (0...3).each do |j|
            w_1 = nodes.find_index(gap_stem[j])
            if w_1.nil?
              nodes << gap_stem[j]
              w_1 = nodes.size - 1
            end

            forms[gap_stem[j]] ||= []
            forms[gap_stem[j]] << gap[j]

            w_2 = nodes.find_index(gap_stem[j + 1])
            if w_2.nil?
              nodes << gap_stem[j + 1]
              w_2 = nodes.size - 1
            end

            forms[gap_stem[j + 1]] ||= []
            forms[gap_stem[j + 1]] << gap[j + 1]

            edge = edges.find { |e| e[0] == w_1 && e[1] == w_2 }
            if edge
              edge[2] += 1
            else
              edges << [w_1, w_2, 1]
            end
          end
        end

        # Trim the forms of duplicates
        forms.each { |k, v| v.uniq! }

        # Convert to D3-able format
        d3_nodes = nodes.map do |n|
          { name: n,
            forms: forms[n] }
        end

        max_weight = edges.map { |e| e[2] }.max.to_f
        d3_links = edges.map do |e|
          { source: e[0],
            target: e[1],
            strength: e[2].to_f / max_weight }
        end

        # Save out all the data
        data = {
          name: dataset.name,
          word: word,
          d3_nodes: d3_nodes,
          d3_links: d3_links
        }

        # Write it out
        ios = StringIO.new
        ios.write(data.to_json)
        ios.original_filename = 'network.json'
        ios.content_type = 'application/json'
        ios.rewind

        task.result = ios
        ios.close

        # We're done here
        task.finish!
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end
    end
  end
end
