# -*- encoding : utf-8 -*-
require 'csv'

module Jobs
  module Analysis
    # Compare two datasets using the Craig Zeta algorithm
    class CraigZeta < Jobs::Analysis::Base
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
      # @option options [String] :user_id the user whose dataset we are to
      #   work on
      # @option options [String] :dataset_id the dataset to operate on
      # @option options [String] :task_id the analysis task we're working from
      # @option options [String] :other_dataset_id the dataset to compare with
      # @return [void]
      # @example Start a job for comparing two datasets
      #   Jobs::Analysis::CraigZeta.create(user_id: current_user.to_param,
      #                                    dataset_id: dataset.to_param,
      #                                    task_id: task.to_param,
      #                                    other_dataset_id: dataset2.to_param)
      def perform
        at(0, 100, t('common.progress_initializing'))
        standard_options!

        other_datasets = options[:other_datasets]
        fail ArgumentError, 'Wrong number of other datasets provided' unless other_datasets.size == 1
        dataset_2 = @user.datasets.active.find(other_datasets[0])

        # Get the data
        analyzer = RLetters::Analysis::CraigZeta.new(
          @dataset, dataset_2,
          -> (p) { at(p, 100, t('.progress_computing')) })
        analyzer.call

        # Save out all the data
        at(100, 100, t('common.progress_finished'))
        data = {}
        data[:name_1] = @dataset.name
        data[:name_2] = dataset_2.name
        data[:markers_1] = analyzer.dataset_1_markers
        data[:markers_2] = analyzer.dataset_2_markers
        data[:graph_points] = analyzer.graph_points
        data[:zeta_scores] = analyzer.zeta_scores

        # Write it out
        ios = StringIO.new(data.to_json)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'craig_zeta.json'
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
