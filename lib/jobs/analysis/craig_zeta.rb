# -*- encoding : utf-8 -*-
require 'csv'

module Jobs
  module Analysis
    # Compare two datasets using the Craig Zeta algorithm
    class CraigZeta < Jobs::Analysis::Base
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
        2
      end

      # Determine which words mark out differences between two datasets.
      #
      # This saves its data out as a CSV file to be downloaded by the user
      # later.  As of yet, we don't offer display in the browser; I think this
      # data is so complex that you'll want to pull it up on a spreadsheet.
      #
      # @param [Hash] args parameters for this job
      # @option args [String] user_id the user whose dataset we are to work on
      # @option args [String] dataset_id the dataset to operate on
      # @option args [String] task_id the analysis task we're working from
      # @option args [String] other_dataset_id the dataset to compare with
      # @return [undefined]
      # @example Start a job for comparing two datasets
      #   Resque.enqueue(Jobs::Analysis::CraigZeta,
      #                  user_id: current_user.to_param,
      #                  dataset_id: dataset.to_param,
      #                  task_id: task.to_param,
      #                  other_dataset_id: dataset2.to_param)
      def self.perform(args = { })
        args.symbolize_keys!
        args.remove_blank!

        # Fetch the user based on ID
        user = User.find(args[:user_id])
        fail ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset_1 = user.datasets.active.find(args[:dataset_id])
        fail ArgumentError, 'Dataset ID is not valid' unless dataset_1

        # Fetch the comparison dataset based on ID
        other_datasets = args[:other_datasets]
        fail ArgumentError, 'Wrong number of other datasets provided' unless other_datasets.count == 1
        dataset_2 = user.datasets.active.find(other_datasets[0])
        fail ArgumentError, 'Other dataset ID is not valid' unless dataset_2

        # Update the analysis task
        task = dataset_1.analysis_tasks.find(args[:task_id])
        fail ArgumentError, 'Task ID is not valid' unless task

        task.name = t('.short_desc')
        task.save

        # Do the analysis

        # 1) Get word lists for each dataset.  Break the datasets up into
        # blocks when you do.  500-word blocks, BigLast.  Stop lists aren't
        # needed, because we're going to remove common words below.
        analyzer_1 = WordFrequencyAnalyzer.new(
          dataset_1,
          block_size: 500,
          split_across: true,
          last_block: :big_last
        )
        analyzer_2 = WordFrequencyAnalyzer.new(
          dataset_2,
          block_size: 500,
          split_across: true,
          last_block: :big_last
        )

        # 2) Cull any word that appears in *every* block.
        block_counts = {}
        analyzer_1.blocks.each do |b|
          b.keys.each do |k|
            block_counts[k] ||= 0
            block_counts[k] += 1
          end
        end
        analyzer_2.blocks.each do |b|
          b.keys.each do |k|
            block_counts[k] ||= 0
            block_counts[k] += 1
          end
        end

        max_count = analyzer_1.blocks.count + analyzer_2.blocks.count
        block_counts.delete_if { |k, v| v == max_count }

        # 3) For each word, compute the fraction of blocks in dataset A in
        # which the word appears.  Compute the fraction of blocks in dataset
        # B in which the word *doesn't* appear.  Add the two numbers.  This is
        # the Zeta Score.
        zeta_scores = {}
        block_counts.each do |word, v|
          a_count = analyzer_1.blocks.map { |b| b[word] ? 1 : 0 }.reduce(:+)
          not_b_count = analyzer_2.blocks.map { |b| b[word] ? 0 : 1 }.reduce(:+)

          a_frac = Float(a_count) / Float(analyzer_1.blocks.count)
          not_b_frac = Float(not_b_count) / Float(analyzer_2.blocks.count)

          zeta_scores[word] = a_frac + not_b_frac
        end

        # 4) Output words and Zeta scores, sorted descending by score.
        zeta_array = zeta_scores.to_a.sort { |a, b| b[1] <=> a[1] }

        # 5) Take the first 1k and last 1k rows here (or split the list
        # clean in half if there's <2k types), and those are your marker word
        # lists.
        size = [(zeta_array.count / 2).floor, 1000].min

        marker_words = zeta_array.take(size).map { |a| a[0] }
        anti_marker_words = zeta_array.reverse_each.take(size).map { |a| a[0] }

        # 6) For graphing, you want to consider each block, and compute what
        # fraction of the words in the block are words in the A-list and what
        # fraction are words in the B-list.  That gives you an X,Y coordinate
        # for the point.  That shows you your separation.
        graph_points = []
        analyzer_1.blocks.each_with_index do |b, i|
          x_val = Float((marker_words & b.keys).count) / Float(b.keys.count)
          y_val = Float((anti_marker_words & b.keys).count) / Float(b.keys.count)

          graph_points << [x_val, y_val, "#{dataset_1.name}: #{i + 1}"]
        end
        analyzer_2.blocks.each_with_index do |b, i|
          x_val = Float((marker_words & b.keys).count) / Float(b.keys.count)
          y_val = Float((anti_marker_words & b.keys).count) / Float(b.keys.count)

          graph_points << [x_val, y_val, "#{dataset_2.name}: #{i + 1}"]
        end

        # Save out all the data
        data = {}
        data[:name_1] = dataset_1.name
        data[:name_2] = dataset_2.name
        data[:marker_words] = marker_words
        data[:anti_marker_words] = anti_marker_words
        data[:graph_points] = graph_points
        data[:zeta_scores] = zeta_scores

        # Write it out
        ios = StringIO.new
        ios.write(data.to_json)
        ios.original_filename = 'craig_zeta.json'
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
