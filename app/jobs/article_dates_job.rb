
# Plot a dataset's members by year
class ArticleDatesJob < ApplicationJob
  include RLetters::Visualization::CSV

  queue_as :analysis

  # Returns true if this job can be started now
  #
  # @return [Boolean] true if this job is not disabled
  def self.available?
    ENV['ARTICLE_DATES_JOB_DISABLED'].nil?
  end

  # Export the date format data
  #
  # Like all view/multiexport jobs, this job saves its data out as a JSON
  # file and then sends it to the user in various formats depending on
  # user selectons.
  #
  # FIXME: document the values coming into the options hash
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options remaining job options
  # @return [void]
  def perform(task, options = {})
    standard_options(task, options)

    # Get the counts
    result = RLetters::Analysis::CountArticlesByField.call(
      options.merge(
        field: :year,
        dataset: dataset,
        progress: lambda do |p|
          task.at((p.to_f / 100.0 * 90.0).to_i, 100, t('.progress_counting'))
        end
      )
    )

    # Convert the years to integers and sort
    dates = result.counts.to_a
    dates.each { |d| d[0] = Integer(d[0]) }
    dates.sort! { |a, b| a[0] <=> b[0] }

    # Save out the data, including getting the name of the normalization
    # set for pretty display
    norm_set_name = ''
    if result.normalize
      if result.normalization_dataset
        norm_set_name = result.normalization_dataset.name
      else
        norm_set_name = t('.entire_corpus')
      end
      value_header = t('.fraction_column')
    else
      value_header = t('.number_column')
    end
    year_header = Document.human_attribute_name(:year)

    output = { data: dates,
               percent: result.normalize,
               normalization_set: norm_set_name,
               year_header: year_header,
               value_header: value_header }

    # Serialize out to JSON and CSV
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(output.to_json, filename: 'article_dates.json',
                                    content_type: 'application/json')
    end

    csv_string = csv_with_header(header: t('.header',
                                           name: dataset.name)) do |csv|
      write_csv_data(csv: csv,
                     data: dates,
                     data_spec: { year_header => :first,
                                  value_header => :second })
    end
    task.files.create(description: 'Spreadsheet',
                      short_description: 'CSV', downloadable: true) do |f|
      f.from_string(csv_string, filename: 'results.csv',
                                content_type: 'text/csv')
    end

    task.mark_completed
  end
end
