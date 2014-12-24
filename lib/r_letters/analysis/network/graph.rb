
module RLetters
  module Analysis
    module Network
      # A network graph
      #
      # This class allows for creating a network from a body of plain text.
      # The nodes are constructed from the text, and the edges from the
      # adjacency information.
      class Graph
        # @return [Array<Node>] all nodes in the graph
        attr_accessor :nodes

        # @return [Array<Edge>] all edges in the graph
        attr_accessor :edges

        # Create a network of adjacency information from the text.
        #
        # @api public
        # @param [Dataset] dataset the text to analyze
        # @param [String] focal_word if set, place this word at the center
        #   of the network
        # @param [Array<Integer>] gaps the word window sizes to use to create
        #   the network.
        #
        #   The network is created by taking all adjacency information using
        #   sliding windows of the sizes specified in this parameter.  For
        #   example, the default value, which is `[2, 5]`, will result in the
        #   network being created from a two-word sliding window and a
        #   five-word sliding window.
        # @param [String] language the language from which to take stop words
        # @param [Proc] progress If set, a function to call with a percentage
        #   of completion (one `Integer` parameter)
        def initialize(dataset, focal_word = nil, gaps = [2, 5],
                       language = 'en', progress = nil)
          # Save parameters
          if focal_word
            @focal_word = focal_word.mb_chars.downcase.to_s
            @focal_word_stem = focal_word.stem
          end
          @gaps = gaps
          @progress = progress

          # Extract the stop list if provided
          stop_words = []
          if language
            stop_list = ::Documents::StopList.find_by!(language: language)
            stop_words = stop_list.list.split
          end

          # Clear final attributes
          self.nodes = []
          self.edges = []

          # Create the word list from the provided dataset and stop words
          create_word_list(dataset, stop_words)

          # Set the parameters for the progress meter if present
          if @progress
            @progress_base = 33
            @progress_size = 66 / @gaps.size
          end

          # Run the analysis for each of the gaps
          @gaps.each do |g|
            add_nodes_for_gap(g)
          end

          # Final progress tick
          @progress && @progress.call(100)
        end

        # Find a word by its id or its word coverage
        #
        # @api public
        # @param [Hash] options the find options
        # @option options [String] :id if set, find a node based on this value
        #   of its id
        # @option options [String] :stem synonym for `:id`
        # @option options [String] :word if set, find a node based on this
        #   unstemmed word
        # @return [Node] the requested node, or `nil` if not found
        # @example Find the node for the stem `basic`
        #   graph.find_node(id: 'basic')
        #   # => Node(id: 'basic', words: ['basically', ...])
        # @example Find the node containing the word `basically`
        #   graph.find_node(word: 'basically')
        #   # => Node(id: 'basic', words: ['basically', ...])
        def find_node(options)
          options[:id] = options.delete(:stem) if options[:stem]

          unless options[:word] || options[:id]
            fail ArgumentError, 'no find option specified'
          end

          if options[:word]
            word = options[:word].mb_chars.downcase.to_s
            nodes.find do |n|
              n.words.include?(word)
            end
          else
            id = options[:id].mb_chars.downcase.to_s
            nodes.find do |n|
              n.id == id
            end
          end
        end

        # Find the edge connecting the two specified nodes, if it exists
        #
        # Note that our edges are undirected, so the order of the parameters
        # `one` and `two` is not meaningful.
        #
        # @api public
        # @param [String] one the first node ID
        # @param [String] two the second node ID
        # @return [Edge] the edge connecting the two nodes, or `nil`
        def find_edge(one, two)
          edges.find do |e|
            (e.one == one && e.two == two) || (e.two == one && e.one == two)
          end
        end

        # Return the maximum edge weight in the graph
        #
        # @api public
        # @return [Integer] the maximum edge weight
        def max_edge_weight
          edges.map(&:weight).max
        end

        private

        # Create a list of words from the provided dataset
        #
        # This function creates the `@words` variable and scrubs out any
        # words listed in `stop_words`.
        #
        # @api private
        # @param [Dataset] dataset the dataset to analyze
        # @param [Array<String>] stop_words stop words to remove, if any
        # @return [undefined]
        def create_word_list(dataset, stop_words)
          # Create a list of lowercase, stemmed words
          @progress && @progress.call(1)
          enum = RLetters::Datasets::DocumentEnumerator.new(dataset,
                                                            fulltext: true)
          @words = enum.map do |doc|
            doc.fulltext.gsub(/[^A-Za-z ]/, '').mb_chars.downcase.to_s.split
          end

          # Remove stop words and stem
          @progress && @progress.call(17)
          @words = @words.flatten - stop_words
          @words_stem = @words.map(&:stem)
        end

        # Add nodes and edges for a given gap
        #
        # This function adds nodes and edges to the graph for a given size of
        # sliding window.
        #
        # @api private
        # @param [Integer] gap the gap size to use
        # @return [undefined]
        def add_nodes_for_gap(gap)
          @words.each_cons(gap).each_with_index do |gap_words, i|
            # Get the stemmed words to go with the un-stemmed words
            gap_words_stem = @words_stem[i, gap]

            # Update progress meter
            if @progress
              val = (i.to_f / (@words.size - 1).to_f) * @progress_size
              @progress.call(@progress_base + val.to_i)
            end

            # Cull based on focal word (stemmed) if present
            next if @focal_word && !gap_words_stem.include?(@focal_word_stem)

            # Find or create nodes for all of these words
            nodes = gap_words_stem.zip(gap_words).map do |w|
              find_or_add_node(*w)
            end

            nodes.combination(2).each do |pair|
              find_or_add_edge(pair[0].id, pair[1].id)
            end
          end
        end

        # Find a node and return it, or add it if needed
        #
        # @api private
        # @param [String] id the node id to add for
        # @param [String] word the word to add a node for
        # @return [Node] the new or existing node
        def find_or_add_node(id, word)
          node = find_node(id: id)
          if node
            node.words << word unless node.words.include?(word)
            node
          else
            node = Node.new
            node.id = id
            node.words = [word]

            nodes << node
            node
          end
        end

        # Find an edge and increment its weight, or add it if needed
        #
        # @api private
        # @param [String] one the first node on the edge
        # @param [String] two the second node on the edge
        # @return [Edge] the new or existing edge
        def find_or_add_edge(one, two)
          edge = find_edge(one, two)
          if edge
            edge.weight += 1
            edge
          else
            edge = Edge.new
            edge.one = one
            edge.two = two
            edge.weight = 1

            edges << edge
            edge
          end
        end
      end
    end
  end
end
