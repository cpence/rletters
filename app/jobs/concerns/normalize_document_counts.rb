require 'active_support/concern'

# Normalize a set of document counts by dividing by other counts
#
# This concern provides support for converting a dataset from absolute
# counts of documents to relative frequencies, by dividing the counts
# by the counts from some other dataset (or the whole corpus, known as
# the normalization set).
#
# The normalizer works by accepting a hash mapping some field's keys to
# count values.  The field can currently be set to any Solr field.  The
# pseudo-code then looks something like:
#
#     for each entry in the dataset
#       look up that entry in the normalization set
#       divide the dataset entry by the normalization entry
#     end
module NormalizeDocumentCounts
  extend ActiveSupport::Concern

  # Normalize a hash containing absolute counts
  #
  # @param [User] user the user whose datasets we're querying
  # @param [Symbol] field the field against which to normalize.  This
  #   must obviously match the keys in `counts`.  Can be set to any
  #   Solr field.
  # @param [Hash<String, Integer>] counts the counts of documents,
  #   grouped by `field` values
  # @param [Hash] args parameters specifying normalization behavior
  # @option args [String] :normalize_doc_counts if '1', perform
  #   normalization
  # @option args [String] :normalize_doc_dataset the id of the dataset
  #   against which to normalize, or blank if the entire corpus
  # @return [Hash<String, Float>] the counts of documents, normalized
  def normalize_document_counts(user, field, counts, args)
    args.clean_options!
    args = args.with_indifferent_access
    return counts unless args[:normalize_doc_counts] == '1'

    if args[:normalize_doc_dataset]
      normalization_set = user.datasets.active.find(args[:normalize_doc_dataset])
    else
      normalization_set = nil
    end

    normalize_counts = RLetters::Analysis::CountArticlesByField.call(
      field: field,
      dataset: normalization_set)

    ret = counts.each_with_object({}) do |(k, v), out|
      if normalize_counts[k] && normalize_counts[k] > 0
        out[k] = v.to_f / normalize_counts[k]
      else
        # I'm not sure if this is the right thing to do when you give
        # me a dataset that can't properly normalize (i.e., you ask me
        # to compute 1/0).  But at least it won't throw a
        # divide-by-zero.
        out[k] = 0.0
      end
    end

    # Fill in zero values for any missing years in the counts
    range = (ret.keys + normalize_counts.keys).minmax
    Range.new(*range).each do |y|
      ret[y] ||= 0
    end

    ret
  end
end
