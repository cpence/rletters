# frozen_string_literal: true

# Compare two datasets using the Craig Zeta algorithm
class CraigZetaJob < ApplicationJob
  include RLetters::Visualization::CSV

  queue_as :analysis

  # Returns true if this job can be started now
  #
  # @return [Boolean] true if this job is not disabled
  def self.available?
    !(ENV['CRAIG_ZETA_JOB_DISABLED'] || 'false').to_bool
  end

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
      raise ArgumentError, 'Wrong number of other datasets provided'
    end

    # Get the data
    analyzer = RLetters::Analysis::CraigZeta.call(
      dataset_1: datasets[0],
      dataset_2: datasets[1],
      progress: ->(p) { task.at(p, 100, t('.progress_computing')) }
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
                     t('.marker_header', name: datasets[1].name) => :second }
      )
      csv << [''] << ['']

      # Output the graphing points
      csv << [t('.graph_header')]
      csv << ['']
      write_csv_data(
        csv: csv,
        data: analyzer.graph_points,
        data_spec: { t('.marker_column', name: datasets[0].name) => :x,
                     t('.marker_column', name: datasets[1].name) => :y,
                     t('.block_name_column') => :name }
      )
      csv << [''] << ['']

      # Output the Zeta scores
      csv << [t('.zeta_score_header')]
      csv << ['']
      write_csv_data(
        csv: csv,
        data: analyzer.zeta_scores,
        data_spec: { t('.word_column') => :first,
                     t('.score_column') => :second }
      )
    end

    # Only make relatively small word clouds
    word_cloud_size = analyzer.dataset_1_markers.size
    word_cloud_size = 50 if word_cloud_size > 50

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
      score_header: t('.score_column'),
      word_cloud_1_words: Hash[analyzer.zeta_scores.take(word_cloud_size)],
      word_cloud_2_words: Hash[analyzer.zeta_scores.reverse_each.take(word_cloud_size)]
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

    task.mark_completed
  end
end
