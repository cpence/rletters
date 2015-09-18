
# Extract proper noun named entities from documents
class NamedEntitiesJob < BaseJob
  include RLetters::Visualization::CSV

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
  # @param [Datasets::Task] task the task we're working from
  # @return [void]
  def perform(task)
    standard_options(task)

    analyzer = RLetters::Analysis::NamedEntities.new(
      dataset,
      ->(p) { task.at(p, 100, t('.progress_finding')) })
    analyzer.call

    csv_string = csv_with_header(t('.header', name: dataset.name)) do |csv|
      write_csv_data(
        csv,
        # This turns {s => [a, b], ...} into [[s, a], [s, b], ...]
        analyzer.entity_references.map { |k, v| [k].product(v) }.flatten(1),
        { t('.type_column') => :first,
          t('.hit_column') => :second })
    end

    output = { data: analyzer.entity_references,
               csv: csv_string }

    # Write it out
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(output.to_json, filename: 'named_entites.json',
                                    content_type: 'application/json')
    end
    task.mark_completed
  end

  # We don't want users to download the JSON file
  def self.download?
    false
  end
end
