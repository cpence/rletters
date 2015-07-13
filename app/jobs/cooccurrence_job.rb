
# Determine statistically significant cooccurrences in text
class CooccurrenceJob < CSVJob
  # Locate significant associations between words at distance.
  #
  # This saves its data out as a CSV file to be downloaded by the user
  # later.
  #
  # @param [String] user_id the user whose dataset we are to work on
  # @param [String] dataset_id the dataset to operate on
  # @param [String] task_id the task we're working from
  # @param [Hash] options parameters for this job
  # @option options [String] :analysis_type the algorithm to use to
  #   analyze the significance of coocurrences.  Can be `'mi'` (for mutual
  #   information), or `'t'` (for t-test).
  # @option options [String] :num_pairs number of coccurrences to return
  # @option options [String] :stemming the stemming method to use. Can be
  #   +:stem+, +:lemma+, or +:no+.
  # @option options [String] :window the window for searching for
  #   cooccurrences
  # @option options [String] :word the word to search for cooccurrences
  #   with
  # @return [void]
  def perform(user_id, dataset_id, task_id, options)
    standard_options(user_id, dataset_id, task_id)

    options.symbolize_keys!
    fail ArgumentError, 'No cooccurrence word provided' unless options[:word]

    analysis_type = (options[:analysis_type] || :mi).to_sym
    if options[:all] == '1'
      num_pairs = 0
    else
      num_pairs = (options[:num_pairs] || 50).to_i
    end
    word = options[:word].mb_chars.downcase.to_s
    window = (options[:window] || 200).to_i
    stemming = options[:stemming].to_sym if options[:stemming]
    stemming = nil if stemming == :no

    case analysis_type
    when :mi
      algorithm = t('common.scoring.mi')
      column = t('common.scoring.mi_header')
      klass = RLetters::Analysis::Cooccurrence::MutualInformation
    when :t
      algorithm = t('common.scoring.t')
      column = t('common.scoring.t_header')
      klass = RLetters::Analysis::Cooccurrence::TTest
    when :likelihood
      algorithm = t('common.scoring.likelihood')
      column = t('common.scoring.likelihood_header')
      klass = RLetters::Analysis::Cooccurrence::LogLikelihood
    else
      fail ArgumentError, 'Invalid value for analysis_type'
    end

    analyzer = klass.new(
      get_dataset(task_id),
      num_pairs,
      word,
      window,
      stemming,
      ->(p) { get_task(task_id).at(p, 100, t('.progress_computing')) }
    )
    grams = analyzer.call

    # Save out all the data
    write_csv_and_complete(task_id, nil,
                           t('.subheader', test: algorithm)) do |csv|
      csv << [t('.pair'), column]
      grams.each do |w, v|
        csv << [w, v]
      end
    end
  end

  # We don't want users to download the JSON file
  def self.download?
    true
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
    [:mi, :t, :likelihood].map do |sym|
      [t("common.scoring.#{sym}"), sym]
    end
  end
end
