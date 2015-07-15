
# Compare two datasets using the Craig Zeta algorithm
class CraigZetaJob < CSVJob
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

    options.symbolize_keys!
    other_datasets = options[:other_datasets]
    fail ArgumentError, 'Wrong number of other datasets provided' unless other_datasets.size == 1
    dataset_2 = user.datasets.active.find(other_datasets[0])

    # Get the data
    analyzer = RLetters::Analysis::CraigZeta.new(
      dataset, dataset_2,
      -> (p) { task.at(p, 100, t('.progress_computing')) })
    analyzer.call

    # Save out all the data
    csv = write_csv(t('.csv_header', name_1: dataset.name,
                                     name_2: dataset_2.name), '') do |out|
      # Output the marker words
      out << [t('.marker_header', name: dataset.name),
              t('.marker_header', name: dataset_2.name)]

      analyzer.dataset_1_markers.each_with_index do |w, i|
        out << [w, analyzer.dataset_2_markers.at(i)]
      end

      out << [''] << ['']

      # Output the graphing points
      out << [t('.graph_header')]
      out << ['']
      out << [t('.marker_column', name: dataset.name),
              t('.marker_column', name: dataset_2.name),
              t('.block_name_column')]
      analyzer.graph_points.each { |l| out << l }

      out << [''] << ['']

      # Output the Zeta scores
      out << [t('.zeta_score_header')]
      analyzer.zeta_scores.each { |(w, s)| out << [w, s] }
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
    ios = StringIO.new(data.to_json)
    file = Paperclip.io_adapters.for(ios)
    file.original_filename = 'craig_zeta.json'
    file.content_type = 'application/json'

    task.result = file
    task.mark_completed
  end

  # We don't want users to download the JSON file
  def self.download?
    false
  end
end
