# frozen_string_literal: true

module RLetters
  module Analysis
    # Compute significant marker words for two datasets, Craig Zeta algorithm
    #
    # Marker words for dataset 1 appears as the first words in the zeta score
    # list. Marker words for dataset 2 appear (in reverse order) as the last
    # words in the zeta score list. The analyzer also creates a graph that
    # demonstrates the separation between the two datasets.
    #
    # @!attribute dataset_1
    #   @return [Dataset] the first dataset to compare
    # @!attribute dataset_2
    #   @return [Dataset] the second dataset to compare
    # @!attribute progress
    #   @return [Proc] if set, a function to call with percentage of completion
    #     (one integer parameter)
    # @!attribute [r] zeta_scores
    #   @return [Hash<String, Float>] the list of zeta scores for each
    #     of the words in the dataset, sorted by significance.
    # @!attribute [r] dataset_1_markers
    #   @return [Array<String>] the list of words that indicate a paper would
    #     be likely to be a member of dataset 1 (as opposed to 2)
    # @!attribute [r] dataset_2_markers
    #   @return [Array<String>] the list of words that indicate a paper would
    #     be likely to be a member of dataset 2 (as opposed to 1)
    # @!attribute [r] graph_points
    #   @return [Array<Point>] the list of points for the
    #     separation graph. Arrays of X coordinate, Y coordinate, and point
    #     labels.
    class CraigZeta
      # A class that encapsulates an X-Y point for CraigZeta
      #
      # @!attribute x
      #   @return [Float] the x coordinate
      # @!attribute y
      #   @return [Float] the y coordinate
      # @!attribute name
      #   @return [String] a description of this point (its segment name)
      class Point
        include Virtus.model(strict: true, required: true, nullify_blank: true)

        attribute :x, Float
        attribute :y, Float
        attribute :name, String

        # Return these in an `[x, y, name]` array.
        #
        # @return [Array<Float, Float, String>] `[x, y, name]`
        def to_a
          [x, y, name]
        end
      end

      include Service
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :dataset_1, Dataset, required: true
      attribute :dataset_2, Dataset, required: true
      attribute :progress, Proc

      attribute :zeta_scores, Hash[String => Float], writer: :private
      attribute :dataset_1_markers, Array[String], writer: :private
      attribute :dataset_2_markers, Array[String], writer: :private
      attribute :graph_points, Array[Point], writer: :private

      attribute :analyzer_1, RLetters::Analysis::Frequency::FromPosition,
                reader: :private, writer: :private
      attribute :analyzer_2, RLetters::Analysis::Frequency::FromPosition,
                reader: :private, writer: :private
      attribute :block_counts, Hash[String => Integer],
                reader: :private, writer: :private

      # Perform the Craig Zeta marker word analysis
      #
      # @return [self]
      def call
        create_analyzers
        compute_block_counts
        compute_zeta_scores
        compute_graph_points
        progress&.call(100)

        self
      end

      private

      # Create frequency analyzers for both datasets
      #
      # Break the datasets up into 500-word blocks, with big last blocks. No
      # need for stop lists, because we're going to remove common words later
      # in the algorithm.
      #
      # This function sets the instance variables +@analyzer_1+ and
      # +@analyzer_2+, corresponding to the two datasets.
      #
      # @return [void]
      def create_analyzers
        self.analyzer_1 = Frequency.call(
          dataset: dataset_1,
          block_size: 500,
          last_block: :big_last,
          split_across: true,
          progress: ->(p) { progress&.call((p.to_f * 0.25).to_i) }
        )

        self.analyzer_2 = Frequency.call(
          dataset: dataset_2,
          block_size: 500,
          last_block: :big_last,
          split_across: true,
          progress: ->(p) { progress&.call((p.to_f * 0.25).to_i + 25) }
        )
      end

      # Convert from word blocks to counts of blocks
      #
      # The instance variable +@block_counts+ will be filled in with the
      # number of 500-word blocks in which each word in the dataset appears.
      #
      # @return [void]
      def compute_block_counts
        progress&.call(50)

        # Convert to numbers of blocks in which each word appears
        self.block_counts = {}
        [analyzer_1.blocks, analyzer_2.blocks].each do |blocks|
          blocks.each do |b|
            b.each_key do |k|
              block_counts[k] ||= 0
              block_counts[k] += 1
            end
          end
        end

        # Delete from the blocks any word which appears in *every* block
        max_count = analyzer_1.blocks.size + analyzer_2.blocks.size
        block_counts.delete_if { |_, v| v == max_count }
      end

      # Convert the block counts to zeta scores
      #
      # For each word, compute the fraction of blocks in dataset 1 in which the
      # word appears, and the fraction of blocks in dataset 2 in which the
      # word doesn't appear. Add the two numbers. This is the zeta score.
      #
      # Zeta scores will be stored in the attribute +zeta_scores+,
      # sorted descending. The first and last 1000 marker words will be saved
      # in +dataset_1_markers+ and +dataset_2_markers+.
      #
      # @return [void]
      def compute_zeta_scores
        zeta_hash = {}
        total = block_counts.size
        block_counts.each_with_index do |(word, _), i|
          progress&.call(50 + (i.to_f / total.to_f * 25.0).to_i)

          a_count = analyzer_1.blocks.map { |b| b[word] ? 1 : 0 }.reduce(:+)
          not_b_count = analyzer_2.blocks.map { |b| b[word] ? 0 : 1 }.reduce(:+)

          a_frac = a_count.to_f / analyzer_1.blocks.size.to_f
          not_b_frac = not_b_count.to_f / analyzer_2.blocks.size.to_f

          zeta_hash[word] = a_frac + not_b_frac
        end

        progress&.call(75)

        # Sort
        self.zeta_scores = zeta_hash.sort { |a, b| b[1] <=> a[1] }

        # Take marker words
        size = [(zeta_scores.size / 2).floor, 1000].min

        self.dataset_1_markers = zeta_scores.take(size).map { |a| a[0] }
        self.dataset_2_markers = zeta_scores.reverse_each.take(size).map { |a| a[0] }
      end

      # Create the graph points array
      #
      # Consider each block, and compute what fraction of the words in the
      # block are in the list for dataset 1 and what fraction are words in
      # dataset 2. That gives you an X-Y coordinate for a point, which when
      # graphed shows you the separation between the datasets.
      #
      # @return [void]
      def compute_graph_points
        progress&.call(80)

        self.graph_points = []

        [[analyzer_1.blocks, dataset_1.name],
         [analyzer_2.blocks, dataset_2.name]].each do |(blocks, name)|
          blocks.each_with_index do |b, i|
            x_val = (dataset_1_markers & b.keys).size.to_f / b.keys.size.to_f
            y_val = (dataset_2_markers & b.keys).size.to_f / b.keys.size.to_f

            graph_points << Point.new(x: x_val, y: y_val,
                                      name: "#{name}: #{i + 1}")
          end
        end
      end
    end
  end
end
