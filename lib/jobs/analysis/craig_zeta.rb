# -*- encoding : utf-8 -*-
require 'csv'

module Jobs
  module Analysis
    # Compare two datasets using the Craig Zeta algorithm
    class CraigZeta < Jobs::Analysis::Base
      include Resque::Plugins::Status

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
        2
      end

      # Determine which words mark out differences between two datasets.
      #
      # This saves its data out as a CSV file to be downloaded by the user
      # later.  As of yet, we don't offer display in the browser; I think this
      # data is so complex that you'll want to pull it up on a spreadsheet.
      #
      # @param [Hash] options parameters for this job
      # @option options [String] user_id the user whose dataset we are to work on
      # @option options [String] dataset_id the dataset to operate on
      # @option options [String] task_id the analysis task we're working from
      # @option options [String] other_dataset_id the dataset to compare with
      # @return [undefined]
      # @example Start a job for comparing two datasets
      #   Jobs::Analysis::CraigZeta.create(user_id: current_user.to_param,
      #                                    dataset_id: dataset.to_param,
      #                                    task_id: task.to_param,
      #                                    other_dataset_id: dataset2.to_param)
      def perform
        options.symbolize_keys!
        options.remove_blank!
        at(0, 100, 'Initializing...')

        user = User.find(options[:user_id])
        dataset_1 = user.datasets.active.find(options[:dataset_id])

        other_datasets = options[:other_datasets]
        fail ArgumentError, 'Wrong number of other datasets provided' unless other_datasets.size == 1
        dataset_2 = user.datasets.active.find(other_datasets[0])

        task = dataset_1.analysis_tasks.find(options[:task_id])
        task.name = t('.short_desc')
        task.save

        # Do the analysis

        # 1) Get word lists for each dataset.  Break the datasets up into
        # blocks when you do.  500-word blocks, BigLast.  Stop lists aren't
        # needed, because we're going to remove common words below.
        doc_segmenter = RLetters::Documents::Segments.new(nil,
                                                          block_size: 500,
                                                          last_block: :big_last)

        set_segmenter_1 = RLetters::Datasets::Segments.new(dataset_1,
                                                           doc_segmenter,
                                                           split_across: true)
        analyzer_1 = RLetters::Analysis::Frequency::FromPosition.new(
          set_segmenter_1,
          ->(p) { at((p.to_f * 25.0).to_i, 100, 'Analyzing words in first dataset...') })

        set_segmenter_2 = RLetters::Datasets::Segments.new(dataset_2,
                                                           doc_segmenter,
                                                           split_across: true)
        analyzer_2 = RLetters::Analysis::Frequency::FromPosition.new(
          set_segmenter_2,
          ->(p) { at((p.to_f * 25.0).to_i + 25, 100, 'Analyzing words in second dataset...') })

        # 2) Cull any word that appears in *every* block.
        at(50, 100, 'Removing words that appear in all blocks...')
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

        max_count = analyzer_1.blocks.size + analyzer_2.blocks.size
        block_counts.delete_if { |k, v| v == max_count }

        # 3) For each word, compute the fraction of blocks in dataset A in
        # which the word appears.  Compute the fraction of blocks in dataset
        # B in which the word *doesn't* appear.  Add the two numbers.  This is
        # the Zeta Score.
        zeta_scores = {}
        total = block_counts.size
        block_counts.each_with_index do |(word, v), i|
          at(50 + (i.to_f / total.to_f * 25.0).to_i, 100,
             "Computing Zeta scores: #{i}/#{total}...")

          a_count = analyzer_1.blocks.map { |b| b[word] ? 1 : 0 }.reduce(:+)
          not_b_count = analyzer_2.blocks.map { |b| b[word] ? 0 : 1 }.reduce(:+)

          a_frac = Float(a_count) / Float(analyzer_1.blocks.size)
          not_b_frac = Float(not_b_count) / Float(analyzer_2.blocks.size)

          zeta_scores[word] = a_frac + not_b_frac
        end

        # 4) Output words and Zeta scores, sorted descending by score.
        at(75, 100, 'Sorting Zeta scores...')
        zeta_array = zeta_scores.to_a.sort { |a, b| b[1] <=> a[1] }

        # 5) Take the first 1k and last 1k rows here (or split the list
        # clean in half if there's <2k types), and those are your marker word
        # lists.
        at(78, 100, 'Taking marker words for each dataset...')
        size = [(zeta_array.size / 2).floor, 1000].min

        marker_words = zeta_array.take(size).map { |a| a[0] }
        anti_marker_words = zeta_array.reverse_each.take(size).map { |a| a[0] }

        # 6) For graphing, you want to consider each block, and compute what
        # fraction of the words in the block are words in the A-list and what
        # fraction are words in the B-list.  That gives you an X,Y coordinate
        # for the point.  That shows you your separation.
        graph_points = []
        analyzer_1.blocks.each_with_index do |b, i|
          at(80 + (i.to_f / analyzer_1.blocks.size.to_f * 10.0).to_i, 100,
             "Calculating separation graph points for first dataset: #{i}/#{analyzer_1.blocks.size}")

          x_val = Float((marker_words & b.keys).size) / Float(b.keys.size)
          y_val = Float((anti_marker_words & b.keys).size) / Float(b.keys.size)

          graph_points << [x_val, y_val, "#{dataset_1.name}: #{i + 1}"]
        end
        analyzer_2.blocks.each_with_index do |b, i|
          at(90 + (i.to_f / analyzer_2.blocks.size.to_f * 10.0).to_i, 100,
             "Calculating separation graph points for second dataset: #{i}/#{analyzer_2.blocks.size}")

          x_val = Float((marker_words & b.keys).size) / Float(b.keys.size)
          y_val = Float((anti_marker_words & b.keys).size) / Float(b.keys.size)

          graph_points << [x_val, y_val, "#{dataset_2.name}: #{i + 1}"]
        end

        # Save out all the data
        at(100, 100, 'Finished, generating output...')
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

        completed
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end
    end
  end
end
