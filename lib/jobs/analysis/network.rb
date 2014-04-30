# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Examine the network of words associated with a focal term
    class Network < Jobs::Analysis::Base
      include Resque::Plugins::Status
      add_concern 'ComputeWordFrequencies'

      # Set the queue for this task
      def self.queue
        :analysis
      end

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
      # @param [Hash] options parameters for this job
      # @option options [String] user_id the user whose dataset we are to work on
      # @option options [String] dataset_id the dataset to operate on
      # @option options [String] task_id the analysis task we're working from
      # @option options [String] word the focal word to analyze
      # @return [undefined]
      # @example Start a job for examining a word network
      #   Jobs::Analysis::Collocation.create(user_id: current_user.to_param,
      #                                      dataset_id: dataset.to_param,
      #                                      task_id: task.to_param,
      #                                      word: 'test')
      def perform
        options.clean_options!
        at(0, 1, 'Initializing...')

        user = User.find(options[:user_id])
        dataset = user.datasets.active.find(options[:dataset_id])
        task = dataset.analysis_tasks.find(options[:task_id])

        task.name = t('.short_desc')
        task.save

        # Fetch the focal word
        word = options[:word].mb_chars.downcase.to_s
        fail ArgumentError, 'Focal word not specified' unless word
        word_stem = word.stem

        # Get the stop word list
        stop_words = Documents::StopList.find_by!(language: 'en').list.split

        # Create a list of lowercase words
        at(1, 100, 'Generating list of words for documents...')
        enum = RLetters::Datasets::DocumentEnumerator.new(dataset, fulltext: true)
        words = enum.map do |doc|
          doc.fulltext.gsub(/[^A-Za-z ]/, '').downcase.split
        end

        # Remove stop words and stem
        at(17, 100, 'Cleaning and stemming list of words...')
        words = words.flatten - stop_words
        words_stem = words.map { |w| w.stem }

        # Storage for the graph
        nodes = []
        forms = {}
        edges = []
        total = words.size

        # Scan with two-word gap
        words.each_cons(2).each_with_index do |gap, i|
          at(33 + ((i.to_f / (total - 1).to_f) * 33.0).to_i, 100,
             "Scanning network with two-word gap: #{i}/#{total - 1}")

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
          at(66 + ((i.to_f / (total - 4).to_f) * 33.0).to_i, 100,
             "Scanning network with five-word gap: #{i}/#{total - 4}")

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
        at(99, 100, 'Cleaning list of words and converting...')
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
        at(100, 100, 'Finished, generating output...')
        data = {
          name: dataset.name,
          word: word,
          d3_nodes: d3_nodes,
          d3_links: d3_links
        }

        # Write it out
        ios = StringIO.new(data.to_json)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'network.json'
        file.content_type = 'application/json'

        task.result = file

        # We're done here
        task.finish!

        completed
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end
    end
  end
end
