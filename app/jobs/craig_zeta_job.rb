
# Compare two datasets using the Craig Zeta algorithm
class CraigZetaJob < BaseJob
  include RLetters::Visualization::CSV
  include RLetters::Visualization::PDF

  # Return how many datasets this job requires
  #
  # @return [Integer] number of datasets needed to perform this job
  def self.num_datasets
    2
  end

  # Determine which words mark out differences between two datasets.
  #
  # This saves its data out as a CSV file to be downloaded by the user
  # later.  As of yet, we don't offer display in the browser; I think this
  # data is so complex that you'll want to pull it up on a spreadsheet.
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options parameters for this job
  # @option options [Array<String>] :other_datasets the dataset to compare
  #   with (should have one member in array)
  # @return [void]
  def perform(task, options)
    standard_options(task, options)

    unless datasets.size == 2
      fail ArgumentError, 'Wrong number of other datasets provided'
    end
    make_word_cloud = options[:word_cloud] == '1'

    # Get the data
    analyzer = RLetters::Analysis::CraigZeta.call(
      dataset_1: datasets[0],
      dataset_2: datasets[1],
      progress: lambda do |p|
        if make_word_cloud
          task.at((p / 100) * 60, 60, t('.progress_computing'))
        else
          task.at(p, 100, t('.progress_computing'))
        end
      end
    )

    # Save out all the data
    csv_string = csv_with_header(header: t('.csv_header',
                                           name_1: datasets[0].name,
                                           name_2: datasets[1].name)) do |csv|
      # Output the marker words
      write_csv_data(
        csv: csv,
        data: analyzer.dataset_1_markers.zip(analyzer.dataset_2_markers),
        data_spec: { t('.marker_header', name: datasets[0].name) => :first,
                     t('.marker_header', name: datasets[1].name) => :second })
      csv << [''] << ['']

      # Output the graphing points
      csv << [t('.graph_header')]
      csv << ['']
      write_csv_data(
        csv: csv,
        data: analyzer.graph_points,
        data_spec: { t('.marker_column', name: datasets[0].name) => :x,
                     t('.marker_column', name: datasets[1].name) => :y,
                     t('.block_name_column') => :name })
      csv << [''] << ['']

      # Output the Zeta scores
      csv << [t('.zeta_score_header')]
      csv << ['']
      write_csv_data(
        csv: csv,
        data: analyzer.zeta_scores,
        data_spec: { t('.word_column') => :first,
                     t('.score_column') => :second })
    end

    data = {
      name_1: datasets[0].name,
      name_2: datasets[1].name,
      markers_1: analyzer.dataset_1_markers,
      markers_2: analyzer.dataset_2_markers,
      graph_points: analyzer.graph_points.map(&:to_a),
      zeta_scores: analyzer.zeta_scores.to_a,
      marker_1_header: t('.marker_column', name: datasets[0].name),
      marker_2_header: t('.marker_column', name: datasets[1].name),
      word_header: t('.word_column'),
      score_header: t('.score_column')
    }

    # Write it out
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(data.to_json, filename: 'craig_zeta.json',
                                  content_type: 'application/json')
    end

    task.files.create(description: 'Spreadsheet',
                      short_description: 'CSV', downloadable: true) do |f|
      f.from_string(csv_string, filename: 'results.csv',
                                content_type: 'text/csv')
    end

    # Make word clouds if requested to do so
    if make_word_cloud
      task.at(60, 100, t('.progress_first_word_cloud'))

      word_cloud_options = {
        color: options[:word_cloud_color],
        font: options[:pdf_font]
      }.compact

      # Only make relatively small word clouds; it's prohibitive to do all
      # 1,000 marker words
      list_size = analyzer.dataset_1_markers.size
      list_size = 50 if list_size > 50

      first_words = Hash[analyzer.zeta_scores.take(list_size)]

      pdf_one = RLetters::Visualization::WordCloud.call(
        word_cloud_options.merge(
          header: t('.marker_column', name: datasets[0].name),
          words: first_words
        )
      )

      task.files.create(description: "Word Cloud (#{datasets[0].name})",
                        short_description: 'PDF', downloadable: true) do |f|
        f.from_string(pdf_one, filename: 'word_cloud_one.pdf',
                               content_type: 'application/pdf')
      end

      task.at(80, 100, t('.progress_second_word_cloud'))

      second_words = Hash[analyzer.zeta_scores.reverse_each.take(list_size)]

      pdf_two = RLetters::Visualization::WordCloud.call(
        word_cloud_options.merge(
          header: t('.marker_column', name: datasets[1].name),
          words: second_words
        )
      )

      task.files.create(description: "Word Cloud (#{datasets[1].name})",
                        short_description: 'PDF', downloadable: true) do |f|
        f.from_string(pdf_two, filename: 'word_cloud_two.pdf',
                               content_type: 'application/pdf')
      end
    end

    task.mark_completed
  end
end
