
# Determine statistically significant cooccurrences in text
class CooccurrenceJob < BaseJob
  include RLetters::Visualization::CSV

  # Locate significant associations between words at distance.
  #
  # This saves its data out as a CSV file to be downloaded by the user
  # later.
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options parameters for this job
  # @option options [String] :scoring the algorithm to use to
  #   analyze the significance of coocurrences.  Can be `'mutual_information'`,
  #   `'log_likelihood'`, or `'t_test'`.
  # @option options [String] :num_pairs number of coccurrences to return
  # @option options [String] :stemming the stemming method to use. Can be
  #   +:stem+, +:lemma+, or +:no+.
  # @option options [String] :window the window for searching for
  #   cooccurrences
  # @option options [String] :word the word to search for cooccurrences
  #   with
  # @return [void]
  def perform(task, options)
    standard_options(task, options)
    options.delete('stemming') if options['stemming'] == 'no'

    case options['scoring']
    when 'mutual_information'
      algorithm = t('common.scoring.mutual_information')
      column = t('common.scoring.mutual_information_header')
    when 't_test'
      algorithm = t('common.scoring.t_test')
      column = t('common.scoring.t_test_header')
    when 'log_likelihood'
      algorithm = t('common.scoring.log_likelihood')
      column = t('common.scoring.loglikelihood_header')
    else
      fail ArgumentError, 'Invalid value for scoring'
    end

    grams = RLetters::Analysis::Cooccurrence.call(options.merge(
      dataset: dataset,
      progress: ->(p) { task.at(p, 100, t('.progress_computing')) }))

    # Save out all the data
    csv_string = csv_with_header(t('.header', name: dataset.name),
                                 t('.subheader', test: algorithm)) do |csv|
      write_csv_data(csv, grams, { t('.pair') => :first,
                                   column => :second })
    end

    # Write out the CSV to a file
    task.files.create(description: 'Spreadsheet',
                      short_description: 'CSV', downloadable: true) do |f|
      f.from_string(csv_string, filename: 'results.csv',
                                content_type: 'text/csv')
    end
    task.mark_completed
  end

  # Helper method for creating the job parameters view
  #
  # This method returns the list of available significance test methods
  # along with their translated user-friendly names, useful for looping
  # over to display them for the user to choose from.
  #
  # @return [Array<(String, Symbol)>] pairs of test method names and their
  #   associated symbols
  def self.significance_tests
    [:mutual_information, :t_test, :log_likelihood].map do |sym|
      [t("common.scoring.#{sym}"), sym]
    end
  end
end
