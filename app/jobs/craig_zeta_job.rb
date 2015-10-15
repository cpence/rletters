
# Compare two datasets using the Craig Zeta algorithm
class CraigZetaJob < BaseJob
  include RLetters::Visualization::CSV
  include RLetters::Visualization::PDF
  include RLetters::Visualization::WordCloud

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
    standard_options(task)

    options = options.with_indifferent_access
    other_datasets = options[:other_datasets]
    unless other_datasets && other_datasets.size == 1
      fail ArgumentError, 'Wrong number of other datasets provided'
    end
    dataset_2 = user.datasets.active.find(other_datasets[0])
    make_word_cloud = options[:word_cloud] == '1'

    # Get the data
    analyzer = RLetters::Analysis::CraigZeta.new(
      dataset_1: dataset,
      dataset_2: dataset_2,
      progress: lambda do |p|
          if make_word_cloud
            task.at((p / 100) * 60, 60, t('.progress_computing'))
          else
            task.at(p, 100, t('.progress_computing'))
          end
        end)
    analyzer.call

    # Save out all the data
    csv = csv_with_header(t('.csv_header', name_1: dataset.name,
                                           name_2: dataset_2.name)) do |csv|
      # Output the marker words
      write_csv_data(csv,
                     analyzer.dataset_1_markers.zip(analyzer.dataset_2_markers),
                     { t('.marker_header', name: dataset.name) => :first,
                       t('.marker_header', name: dataset_2.name) => :second })
      csv << [''] << ['']

      # Output the graphing points
      csv << [t('.graph_header')]
      csv << ['']
      write_csv_data(csv, analyzer.graph_points,
                     { t('.marker_column', name: dataset.name) => :x,
                       t('.marker_column', name: dataset_2.name) => :y,
                       t('.block_name_column') => :name })
      csv << [''] << ['']

      # Output the Zeta scores
      csv << [t('.zeta_score_header')]
      csv << ['']
      write_csv_data(csv, analyzer.zeta_scores,
                     { t('.word_column') => :first,
                       t('.score_column') => :second })
    end

    data = {}
    data[:name_1] = dataset.name
    data[:name_2] = dataset_2.name
    data[:markers_1] = analyzer.dataset_1_markers
    data[:markers_2] = analyzer.dataset_2_markers
    data[:graph_points] = analyzer.graph_points.map { |p| p.to_a }
    data[:zeta_scores] = analyzer.zeta_scores.to_a
    data[:marker_1_header] = t('.marker_column', name: dataset.name)
    data[:marker_2_header] = t('.marker_column', name: dataset_2.name)
    data[:word_header] = t('.word_column')
    data[:score_header] = t('.score_column')

    # Write it out
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(data.to_json, filename: 'craig_zeta.json',
                                  content_type: 'application/json')
    end

    task.files.create(description: 'Spreadsheet',
                      short_description: 'CSV', downloadable: true) do |f|
      f.from_string(csv, filename: 'results.csv', content_type: 'text/csv')
    end

    # Make word clouds if requested to do so
    if make_word_cloud
      task.at(60, 100, t('.progress_first_word_cloud'))

      color = options[:word_cloud_color] || 'Blues'
      font = options[:pdf_font] || 'Roboto'

      # Only make relatively small word clouds; it's prohibitive to do all
      # 1,000 marker words
      list_size = analyzer.dataset_1_markers.size
      list_size = 50 if list_size > 50

      first_words = Hash[analyzer.zeta_scores.take(list_size)]

      pdf_one = word_cloud(t('.marker_column', name: dataset.name),
                           first_words, color, font)

      task.files.create(description: "Word Cloud (#{dataset.name})",
                        short_description: 'PDF', downloadable: true) do |f|
        f.from_string(pdf_one, filename: 'word_cloud_one.pdf',
                               content_type: 'application/pdf')
      end

      task.at(80, 100, t('.progress_second_word_cloud'))

      second_words = Hash[analyzer.zeta_scores.reverse_each.take(list_size)]

      pdf_two = word_cloud(t('.marker_column', name: dataset_2.name),
                           second_words, color, font)

      task.files.create(description: "Word Cloud (#{dataset_2.name})",
                        short_description: 'PDF', downloadable: true) do |f|
        f.from_string(pdf_two, filename: 'word_cloud_two.pdf',
                               content_type: 'application/pdf')
      end
    end

    task.mark_completed
  end
end
