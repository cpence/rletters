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
  # @option args [String] :block_size block size, in words
  #
  #   If this attribute is zero, then we will read from `num_blocks`
  #   instead.  Defaults to zero.
  # @option args [String] :num_blocks number of blocks for splitting
  #
  #   If this attribute is zero, we will read from `block_size` instead.
  #   Defaults to zero.
  # @option args [String] :split_across whether to split blocks across
  #   documents
  #
  #   If this is set to true, then we will effectively concatenate all
  #   the documents before splitting into blocks.  If false, we'll
  #   split blocks on a per-document basis.  Defaults to true.
  # @option args [String] :num_words how many words to keep in the list
  #
  #   If greater than the number of types in the dataset (or zero),
  #   then return all the words.  Defaults to zero.
  # @option args [String] :last_block how to treat the last block
  #
  #   Can be set to big_last, small_last, truncate_last, or
  #   truncate_all.  See the RLetters::Analysis::WordFrequency docs for
  #   more information.
  # @option args [String] :inclusion_list if set, list of words to find
  #
  #   If this attribute is set, then we'll only analyze the words that
  #   are specified here (separated by spaces), and no others.
  # @option args [String] :stop_list if set, language of stop list
  #   to use
  # @option args [String] :exclusion_list if set, list of words to
  #   exclude from analysis
  # @return [RLetters::Analysis::WordFrequency] the computed analysis
  def compute_word_frequencies(dataset, progress = nil, args = {})
    args.clean_options!
    args = args.with_indifferent_access
    convert_args!(args)

    # Quick-out for the FromTF analyzer if we can: only one block,
    # one-grams, no stemming
    if ((args[:num_blocks] && args[:num_blocks] == 1) ||
       (args[:num_blocks].nil? && args[:block_size].nil?)) &&
       (args[:ngrams].nil? || args[:ngrams] == 1) &&
       (args[:stemming].nil?)
      return RLetters::Analysis::Frequency::FromTF.new(
        dataset,
        progress,
        split_across: args.delete(:split_across),
        num_words: args.delete(:num_words),
        inclusion_list: args.delete(:inclusion_list),
        exclusion_list: args.delete(:exclusion_list),
        stop_list: args.delete(:stop_list)
      )
    end

    # Produce a word list generator
    word_lister_options = {
      ngrams: args.delete(:ngrams),
      stemming: args.delete(:stemming)
    }
    @word_lister = RLetters::Documents::WordList.new(word_lister_options)

    # Segment the dataset into text blocks
    doc_segmenter_options = {
      num_blocks: args.delete(:num_blocks),
      block_size: args.delete(:block_size),
      last_block: args.delete(:last_block)
    }
    @doc_segmenter = RLetters::Documents::Segments.new(@word_lister,
                                                       doc_segmenter_options)

    set_segmenter_options = {
      split_across: args.delete(:split_across)
    }
    @set_segmenter = RLetters::Datasets::Segments.new(dataset,
                                                      @doc_segmenter,
                                                      set_segmenter_options)

    # Perform the position-based analysis (with the remaining args)
    RLetters::Analysis::Frequency::FromPosition.new(@set_segmenter, progress, args)
  end

  private

  # Convert all of the job parameters from strings to proper types
  #
  # Since the params are coming in from a form, they'll all be strings.
  # We need them as integer or boolean types, so convert them here.
  #
  # @param [Hash] args the original arguments to the job
  # @return [Hash] args the arguments, with typecast parameters
  def convert_args!(args)
    if args[:word_method] == 'all'
      args[:all] = true
    elsif args[:num_words]
      args[:num_words] = Integer(args[:num_words])
    end

    args[:ngrams] = Integer(args[:ngrams]) if args[:ngrams]
    args[:block_size] = Integer(args[:block_size]) if args[:block_size]
    args[:num_blocks] = Integer(args[:num_blocks]) if args[:num_blocks]
    args[:last_block] = args[:last_block].to_sym if args[:last_block]
    args[:stop_list] = Documents::StopList.find_by(language: args[:stop_list]) if args[:stop_list]
    args[:stemming] = args[:stemming].to_sym if args[:stemming]
    args[:stemming] = nil if args[:stemming] == :no
    args[:inclusion_list] = args[:inclusion_list].mb_chars.downcase.to_s if args[:inclusion_list]
    args[:exclusion_list] = args[:exclusion_list].mb_chars.downcase.to_s if args[:exclusion_list]
    args[:split_across] = false
    args[:split_across] = true if args[:split_across] && args[:split_across] == 1
  end
end
