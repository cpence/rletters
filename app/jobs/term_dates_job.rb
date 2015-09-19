
# Plot occurrences of a term in a dataset by year
class TermDatesJob < BaseJob
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
    standard_options(task)

    # Get the counts and normalize if requested
    options = options.with_indifferent_access
    fail ArgumentError, 'Term for plotting not specified' unless options[:term]
    term = options[:term]
    analyzer = RLetters::Analysis::CountTermsByField.new(
      term,
      dataset,
      ->(p) { task.at(p, 100, t('.progress_computing')) })
    dates = analyzer.counts_for(:year)

    dates = dates.to_a
    dates.each { |d| d[0] = Integer(d[0]) }

    # Fill in zeroes for any years that are missing
    dates = Range.new(*(dates.map { |d| d[0] }.minmax)).each.map do |y|
      dates.assoc(y) || [y, 0]
    end

    csv_string = csv_with_header(t('.header', name: dataset.name),
                                 t('.subheader', term: term)) do |csv|
      write_csv_data(csv, dates,
                     { Document.human_attribute_name(:year) => :first,
                       t('.number_column') => :second })
    end

    # Save out the data
    output = {
      data: dates,
      term: term,
      year_header: Document.human_attribute_name(:year),
      value_header: t('.number_column') }

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
