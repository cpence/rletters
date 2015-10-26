
# Plot a dataset's members by year
class ArticleDatesJob < BaseJob
  include NormalizeDocumentCounts
  include RLetters::Visualization::CSV

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

    # Get the counts and normalize if requested
    dates = RLetters::Analysis::CountArticlesByField.call(
      field: :year,
      dataset: dataset,
      progress: lambda do |p|
        task.at((p.to_f / 100.0 * 90.0).to_i, 100, t('.progress_counting'))
      end)

    task.at(90, 100, t('.progress_normalizing'))
    options = options.with_indifferent_access
    dates = normalize_document_counts(user, :year, dates, options)

    dates = dates.to_a
    dates.each { |d| d[0] = Integer(d[0]) }

    # Fill in zeroes for any years that are missing
    task.at(95, 100, t('.progress_missing'))
    dates = Range.new(*(dates.map { |d| d[0] }.minmax)).each.map do |y|
      dates.assoc(y) || [y, 0]
    end

    # Save out the data, including getting the name of the normalization
    # set for pretty display
    norm_set_name = ''
    if options[:normalize_doc_counts] == '1'
      if options[:normalize_doc_dataset]
        norm_set = user.datasets.active.find(options[:normalize_doc_dataset])
        norm_set_name = norm_set.name
      else
        norm_set_name = t('.entire_corpus')
      end
      value_header = t('.fraction_column')
    else
      value_header = t('.number_column')
    end
    year_header = Document.human_attribute_name(:year)

    output = { data: dates,
               percent: (options[:normalize_doc_counts] == '1'),
               normalization_set: norm_set_name,
               year_header: year_header,
               value_header: value_header }

    # Serialize out to JSON and CSV
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(output.to_json, filename: 'article_dates.json',
                                    content_type: 'application/json')
    end

    csv = csv_with_header(t('.header', name: dataset.name)) do |csv|
      write_csv_data(csv, dates, { year_header => :first,
                                   value_header => :second })
    end
    task.files.create(description: 'Spreadsheet',
                      short_description: 'CSV', downloadable: true) do |f|
      f.from_string(csv, filename: 'results.csv', content_type: 'text/csv')
    end

    task.mark_completed
  end
end
