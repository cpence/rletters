
# Plot occurrences of a term in a dataset by year
class TermDatesJob < TaskJob
  include RLetters::Visualization::CSV

  # Export the date format data
  #
  # Like all view/multiexport jobs, this job saves its data out as a JSON
  # file and then sends it to the user in various formats depending on
  # user selectons.
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options parameters for this job
  # @option options [String] :term the focal word to analyze
  # @return [void]
  def perform(task, options)
    standard_options(task, options)

    # Get the counts
    dates = RLetters::Analysis::CountTermsByField.call(
      term: options[:term],
      field: :year,
      dataset: dataset,
      progress: ->(p) { task.at(p, 100, t('.progress_computing')) })

    # Convert the years to integers and sort
    dates = dates.to_a
    dates.each { |d| d[0] = Integer(d[0]) }
    dates.sort! { |a, b| a[0] <=> b[0] }

    # Save out the data
    year_header = Document.human_attribute_name(:year)
    value_header = t('.number_column')

    csv_string = csv_with_header(header: t('.header', name: dataset.name),
                                 subheader: t('.subheader',
                                              term: options[:term])) do |csv|
      write_csv_data(csv: csv,
                     data: dates,
                     data_spec: {
                       year_header => :first,
                       value_header => :second
                     })
    end

    output = {
      data: dates,
      term: options[:term],
      year_header: year_header,
      value_header: value_header }

    # Serialize out to JSON
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(output.to_json, filename: 'term_dates.json',
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
