require 'active_support/concern'

# Compute word frequencies for a given dataset
#
# This concern just encapsulates obtaining the parameters you need for
# an Analysis::WordFrequency object and creates it.
module ComputeWordFrequencies
  extend ActiveSupport::Concern

  # Compute word frequency data for a given dataset
  #
  # @param [Dataset] dataset the dataset for which to compute
  #   frequencies
  # @param [Proc] progress If set, a function to call with a percentage
  #   of completion (one Integer parameter)
  # @param [Hash] args parameters for frequency analysis
  #
  #   See the attributes of RLetters::Analysis::Frequency::Base for the
  #   acceptable parameters here.
  # @return [RLetters::Analysis::Frequency::Base] the computed analysis
  def compute_word_frequencies(dataset, progress = nil, args = {})
    # Patch up the two strange arguments that don't come in the right format
    # from the web form
    if args['word_method'] == 'all'
      args['all'] = true
    end
    args.delete('stemming') if args['stemming'] == :no

    RLetters::Analysis::Frequency.call(args.merge(dataset: dataset,
                                                  progress: progress))
  end
end
