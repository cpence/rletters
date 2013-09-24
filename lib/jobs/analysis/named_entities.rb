# -*- encoding : utf-8 -*-

module Jobs
  module Analysis

    # Extract proper noun named entities from documents
    class NamedEntities < Jobs::Analysis::Base
      @queue = 'analysis'

      # Export the named entity data
      #
      # This function saves out the NER data as a YAML hash, to be visualized
      # in a number of different ways by the job views.
      #
      # @param [Hash] args parameters for this job
      # @option args [String] user_id the user whose dataset we are to work on
      # @option args [String] dataset_id the dataset to operate on
      # @option args [String] task_id the analysis task we're working from
      # @return [undefined]
      # @example Start a job for computing a dataset's named entities
      #   Resque.enqueue(Jobs::Analysis::NamedEntities,
      #                  user_id: current_user.to_param,
      #                  dataset_id: dataset.to_param,
      #                  task_id: task.to_param)
      def self.perform(args = { })
        args.symbolize_keys!

        # Fetch the user based on ID
        user = User.find(args[:user_id])
        fail ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset = user.datasets.find(args[:dataset_id])
        fail ArgumentError, 'Dataset ID is not valid' unless dataset

        # Update the analysis task
        task = dataset.analysis_tasks.find(args[:task_id])
        fail ArgumentError, 'Task ID is not valid' unless task

        task.name = 'Extract references to proper names'
        task.save

        analyzer = NERAnalyzer.new(dataset)

        # Write it out
        ios = StringIO.new
        ios.write(analyzer.entity_references.to_yaml)
        ios.original_filename = 'named_entites.yml'
        ios.content_type = 'text/yaml'
        ios.rewind

        task.result = ios
        ios.close

        # We're done here
        task.finish!
      end

      # We don't want users to download the YAML file
      def self.download?
        false
      end
    end

  end
end
