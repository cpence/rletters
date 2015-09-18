
# Compare two datasets using the Craig Zeta algorithm
class CraigZetaJob < BaseJob
  include RLetters::Visualization::CSV

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
    fail ArgumentError, 'Wrong number of other datasets provided' unless other_datasets.size == 1
    dataset_2 = user.datasets.active.find(other_datasets[0])

    # Get the data
    analyzer = RLetters::Analysis::CraigZeta.new(
      dataset, dataset_2,
      -> (p) { task.at(p, 100, t('.progress_computing')) })
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
                     { t('.marker_column', name: dataset.name) => :first,
                       t('.marker_column', name: dataset_2.name) => :second,
                       t('.block_name_column') => :third })
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
    data[:graph_points] = analyzer.graph_points
    data[:zeta_scores] = analyzer.zeta_scores
    data[:marker_1_header] = t('.marker_column', name: dataset.name)
    data[:marker_2_header] = t('.marker_column', name: dataset_2.name)
    data[:word_header] = t('.word_column')
    data[:score_header] = t('.score_column')
    data[:csv] = csv

    # Write it out
    task.files.create(description: 'Raw JSON Data',
                      short_description: 'JSON') do |f|
      f.from_string(data.to_json, filename: 'craig_zeta.json',
                                  content_type: 'application/json')
    end
    task.mark_completed
  end

  # We don't want users to download the JSON file
  def self.download?
    false
  end
end
