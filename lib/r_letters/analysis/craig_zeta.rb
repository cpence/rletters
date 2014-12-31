
module RLetters
  module Analysis
    # Compute significant marker words for two datasets, Craig Zeta algorithm
    #
    # Marker words for dataset 1 appears as the first words in the zeta score
    # list. Marker words for dataset 2 appear (in reverse order) as the last
    # words in the zeta score list. The analyzer also creates a graph that
    # demonstrates the separation between the two datasets.
    #
    # @!attribute [r] zeta_scores
    #   @return [Array<Array(String, Float)>] The list of zeta scores for each
    #     of the words in the dataset, sorted by significance.
    # @!attribute [r] dataset_1_markers
    #   @return [Array<String>] The list of words that indicate a paper would
    #     be likely to be a member of dataset 1 (as opposed to 2)
    # @!attribute [r] dataset_2_markers
    #   @return [Array<String>] The list of words that indicate a paper would
    #     be likely to be a member of dataset 2 (as opposed to 1)
    # @!attribute [r] graph_points
    #   @return [Array<Array(Float, Float, String)] The list of points for the
    #     separation graph. Arrays of X coordinate, Y coordinate, and point
    #     labels.
    class CraigZeta
      attr_reader :zeta_scores, :dataset_1_markers,
                  :dataset_2_markers, :graph_points

      # Create a new object for detecting Craig Zeta marker words
      #
      # @param [Dataset] dataset_1 the first dataset to compare
      # @param [Dataset] dataset_2 the second dataset to compare
      # @param [Proc] progress If set, a function to call with a percentage of
      #   completion (one `Integer` parameter)
      def initialize(dataset_1, dataset_2, progress = nil)
        @dataset_1 = dataset_1
        @dataset_2 = dataset_2
        @progress = progress
      end

      # Perform the Craig Zeta marker word analysis
      #
      # All results are returned in the member attributes.
      #
      # @return [undefined]
      def call
        create_analyzers
        compute_block_counts
        compute_zeta_scores
        compute_graph_points
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
      # @return [undefined]
      def create_analyzers
        ds = RLetters::Documents::Segments.new(nil,
                                               block_size: 500,
                                               last_block: :big_last)

        ss1 = RLetters::Datasets::Segments.new(@dataset_1, ds,
                                               split_across: true)
        @analyzer_1 = RLetters::Analysis::Frequency::FromPosition.new(
          ss1,
          ->(p) { @progress && @progress.call((p.to_f * 25.0).to_i) })

        ss2 = RLetters::Datasets::Segments.new(@dataset_2, ds,
                                               split_across: true)
        @analyzer_2 = RLetters::Analysis::Frequency::FromPosition.new(
          ss2,
          ->(p) { @progress && @progress.call((p.to_f * 25.0).to_i + 25) })
      end

      # Convert from word blocks to counts of blocks
      #
      # The instance variable +@block_counts+ will be filled in with the
      # number of 500-word blocks in which each word in the dataset appears.
      #
      # @return [undefined]
      def compute_block_counts
        @progress && @progress.call(50)

        # Convert to numbers of blocks in which each word appears
        @block_counts = {}
        [@analyzer_1.blocks, @analyzer_2.blocks].each do |blocks|
          blocks.each do |b|
            b.keys.each do |k|
              @block_counts[k] ||= 0
              @block_counts[k] += 1
            end
          end
        end

        # Delete from the blocks any word which appears in *every* block
        max_count = @analyzer_1.blocks.size + @analyzer_2.blocks.size
        @block_counts.delete_if { |_, v| v == max_count }
      end

      # Convert the block counts to zeta scores
      #
      # For each word, compute the fraction of blocks in dataset 1 in which the
      # word appears, and the fraction of blocks in dataset 2 in which the
      # word doesn't appear. Add the two numbers. This is the zeta score.
      #
      # Zeta scores will be stored in the instance variable +@zeta_scores+,
      # sorted descending. The first and last 1000 marker words will be saved
      # in +@dataset_1_markers+ and +@dataset_2_markers+.
      #
      # @return [undefined]
      def compute_zeta_scores
        zeta_hash = {}
        total = @block_counts.size
        @block_counts.each_with_index do |(word, _), i|
          @progress && @progress.call(50 + (i.to_f / total.to_f * 25.0).to_i)

          a_count = @analyzer_1.blocks.map { |b| b[word] ? 1 : 0 }.reduce(:+)
          not_b_count = @analyzer_2.blocks.map { |b| b[word] ? 0 : 1 }.reduce(:+)

          a_frac = a_count.to_f / @analyzer_1.blocks.size.to_f
          not_b_frac = not_b_count.to_f / @analyzer_2.blocks.size.to_f

          zeta_hash[word] = a_frac + not_b_frac
        end

        @progress && @progress.call(75)

        # Sort
        @zeta_scores = zeta_hash.to_a.sort { |a, b| b[1] <=> a[1] }

        # Take marker words
        size = [(@zeta_scores.size / 2).floor, 1000].min

        @dataset_1_markers = @zeta_scores.take(size).map { |a| a[0] }
        @dataset_2_markers = @zeta_scores.reverse_each.take(size).map { |a| a[0] }
      end

      # Create the graph points array
      #
      # Consider each block, and compute what fraction of the words in the
      # block are in the list for dataset 1 and what fraction are words in
      # dataset 2. That gives you an X-Y coordinate for a point, which when
      # graphed shows you the separation between the datasets.
      #
      # @return [undefined]
      def compute_graph_points
        @progress && @progress.call(80)

        @graph_points = []

        [[@analyzer_1.blocks, @dataset_1.name],
         [@analyzer_2.blocks, @dataset_2.name]].each do |(blocks, name)|
          blocks.each_with_index do |b, i|
            x_val = (@dataset_1_markers & b.keys).size.to_f / b.keys.size.to_f
            y_val = (@dataset_2_markers & b.keys).size.to_f / b.keys.size.to_f

            @graph_points << [x_val, y_val, "#{name}: #{i + 1}"]
          end
        end
      end
    end
  end
end
