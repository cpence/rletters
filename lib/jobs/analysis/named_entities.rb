
module Jobs
  module Analysis
    # Extract proper noun named entities from documents
    class NamedEntities < Jobs::Analysis::CSVJob
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
      # @param [String] user_id the user whose dataset we are to work on
      # @param [String] dataset_id the dataset to operate on
      # @param [String] task_id the task we're working from
      # @return [void]
      def self.perform(user_id, dataset_id, task_id)
        standard_options(user_id, dataset_id, task_id)

        analyzer = RLetters::Analysis::NamedEntities.new(
          get_dataset(task_id),
          ->(p) { get_task(task_id).at(p, 100, t('.progress_finding')) })
        analyzer.call

        csv = write_csv(task_id, nil, '') do |out|
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
        ios = StringIO.new(output.to_json)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'named_entites.json'
        file.content_type = 'application/json'

        task = get_task(task_id)
        task.result = file
        task.mark_completed
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end
    end
  end
end
