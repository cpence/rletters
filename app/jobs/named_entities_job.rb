# frozen_string_literal: true

# Extract proper noun named entities from documents
class NamedEntitiesJob < ApplicationJob
  include RLetters::Visualization::CSV

  queue_as :analysis

  # Returns true if this job can be started now
  #
  # @return [Boolean] true if the Stanford NLP toolkit is available and this
  #   job is not disabled
  def self.available?
    ENV['NLP_TOOL_PATH'].present? && ENV['NAMED_ENTITIES_JOB_DISABLED'].nil?
  end

  # Export the named entity data
  #
  # This function saves out the NER data as a JSON hash, to be visualized
  # in a number of different ways by the job views.
  #
  # @param [Datasets::Task] task the task we're working from
  # @return [void]
  def perform(task)
    standard_options(task)

    refs = RLetters::Analysis::NamedEntities.call(
      dataset: dataset,
      progress: ->(p) { task.at(p, 100, t('.progress_finding')) }
    )
    refs ||= {}

    csv_string = csv_with_header(header: t('.header',
                                           name: dataset.name)) do |csv|
      write_csv_data(
        csv: csv,
        # This turns {s => [a, b], ...} into [[s, a], [s, b], ...]
        data: refs.flat_map { |k, v| [k].product(v) },
        data_spec: { t('.type_column') => :first,
                     t('.hit_column') => :second }
      )
    end

    output = { data: refs }

    # Write it out
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(output.to_json, filename: 'named_entites.json',
                                    content_type: 'application/json')
    end

    task.files.create(description: 'Spreadsheet',
                      short_description: 'CSV', downloadable: true) do |f|
      f.from_string(csv_string, filename: 'results.csv',
                                content_type: 'text/csv')
    end

    task.mark_completed
  end
end
