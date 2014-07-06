# -*- encoding : utf-8 -*-
# No test coverage here, as we aren't installing the Stanford NLP package on
# Travis.
# :nocov:

module Jobs
  module Analysis
    # Extract proper noun named entities from documents
    class NamedEntities < Jobs::Analysis::Base
      include Resque::Plugins::Status

      # Set the queue for this task
      #
      # @return [Symbol] the queue on which this job should run
      def self.queue
        :analysis
      end

      # Returns true if this job can be started now
      #
      # @return [Boolean] true if the Stanford NLP toolkit is available
      def self.available?
        Admin::Setting.nlp_tool_path.present?
      end

      # Return how many datasets this job requires
      #
      # @return [Integer] number of datasets needed to perform this job
      def self.num_datasets
        1
      end

      # Export the named entity data
      #
      # This function saves out the NER data as a JSON hash, to be visualized
      # in a number of different ways by the job views.
      #
      # @param [Hash] options parameters for this job
      # @option options [String] :user_id the user whose dataset we are to
      #   work on
      # @option options [String] :dataset_id the dataset to operate on
      # @option options [String] :task_id the analysis task we're working from
      # @return [void]
      # @example Start a job for computing a dataset's named entities
      #   Jobs::Analysis::NamedEntities.create(user_id: current_user.to_param,
      #                                        dataset_id: dataset.to_param,
      #                                        task_id: task.to_param)
      def perform
        options.clean_options!
        at(0, 100, t('common.progress_initializing'))

        user = User.find(options[:user_id])
        dataset = user.datasets.active.find(options[:dataset_id])
        task = dataset.analysis_tasks.find(options[:task_id])

        task.name = t('.short_desc')
        task.save

        analyzer = RLetters::Analysis::NamedEntities.new(
          dataset,
          ->(p) { at(p, 100, t('.progress_finding')) })

        # Write it out
        at(100, 100, t('common.progress_finished'))
        ios = StringIO.new(analyzer.entity_references.to_json)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'named_entites.json'
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
