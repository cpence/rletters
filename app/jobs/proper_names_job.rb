# frozen_string_literal: true

# Extract proper nouns from documents
class ProperNamesJob < ApplicationJob
  include RLetters::Visualization::Csv

  queue_as :analysis

  # Returns true if this job can be started now
  #
  # @return [Boolean] true if this job is not disabled
  def self.available?
    !(ENV['PROPER_NAMES_JOB_DISABLED'] || 'false').to_boolean
  end

  # Export the proper name data
  #
  # This function saves out the proper names as a JSON array, to be visualized
  # by the job views.
  #
  # @param [Datasets::Task] task the task we're working from
  # @return [void]
  def perform(task)
    standard_options(task)

    refs = RLetters::Analysis::ProperNames.call(
      dataset: dataset,
      progress: ->(p) { task.at(p, 100, t('.progress_finding')) }
    )
    refs ||= {}

    csv_string = csv_with_header(header: t('.header',
                                           name: dataset.name)) do |csv|
      write_csv_data(
        csv: csv,
        data: refs,
        data_spec: { t('.name_column') => :first,
                     t('.count_coumnt') => :second }
      )
    end

    output = { names: refs }

    # Write it out
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(output.to_json, filename: 'proper_names.json',
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
