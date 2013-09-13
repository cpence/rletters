# -*- encoding : utf-8 -*-
require 'active_support/concern'

module Jobs
  module Analysis

    # Namespace containing all analysis-job concerns
    module Concerns

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
        # @param [Dataset] normalization set the dataset to normalize against.
        #   If +nil+, then normalize against the entire corpus.
        # @param [Symbol] field the field against which to normalize.  This
        #   must obviously match the keys in +counts+.  Can be set to any Solr
        #   field.
        # @param [Hash<String, Integer>] counts the counts of documents,
        #   grouped by +field+ values
        # @param [Hash<String, Float>] the counts of documents, normalized
        def normalize_document_counts(normalization_set, field, counts)
          normalize_counts = Solr::DataHeplpers::count_by_field(normalization_set, field)

          ret = {}
          counts.each do |k, v|
            if normalize_counts[k] && normalize_counts[k] > 0
              ret[k] = v.to_f / normalize_counts[k]
            else
              # I'm not sure if this is the right thing to do when you give
              # me a dataset that can't properly normalize (i.e., you ask me
              # to compute 1/0).  But at least it won't throw a
              # divide-by-zero.
              ret[k] = 0.0
            end
          end
          ret
        end
      end
    end

  end
end
