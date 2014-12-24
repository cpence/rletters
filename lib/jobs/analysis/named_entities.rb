
module Jobs
  module Analysis
    # Extract proper noun named entities from documents
    class NamedEntities < Jobs::Analysis::CSVJob
      include Resque::Plugins::Status

      # Returns true if this job can be started now
      #
      # @return [Boolean] true if the Stanford NLP toolkit is available
      def self.available?
        Admin::Setting.nlp_tool_path.present?
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
        at(0, 100, t('common.progress_initializing'))
        standard_options!

        analyzer = RLetters::Analysis::NamedEntities.new(
          @dataset,
          ->(p) { at(p, 100, t('.progress_finding')) })
        analyzer.call

        csv = write_csv(nil, '') do |out|
          out << [t('.type_column'), t('.hit_column')]
          analyzer.entity_references.each do |category, list|
            list.each do |hit|
              out << [category, hit]
            end
          end
        end

        output = { data: analyzer.entity_references,
                   csv: csv }

        # Write it out
        at(100, 100, t('common.progress_finished'))
        ios = StringIO.new(output.to_json)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'named_entites.json'
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
