# frozen_string_literal: true

module RLetters
  module Analysis
    # Code for counting the number of articles in a dataset, grouped by a field
    #
    # @!attribute field
    #   @return [Symbol] the field to group by
    # @!attribute dataset
    #   @return [Dataset] if set, the dataset to analyze (else the entire
    #     corpus)
    # @!attribute normalize
    #   @return [Boolean] if true, divide the counts for `dataset` by the
    #     counts for the same field in `normalization_dataset` before returning
    # @!attribute normalization_dataset
    #   @return [Dataset] dataset to normalize by (or nil for the whole corpus)
    # @!attribute progress
    #   @return [Proc] if set, a function to call with percentage of completion
    #     (one integer parameter)
    class CountArticlesByField
      include Service
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :field, Symbol
      attribute :dataset, Dataset
      attribute :normalize, Boolean, default: false
      attribute :normalization_dataset, VirtusExt::DatasetID
      attribute :progress, Proc

      # Count up a dataset (or the corpus) by a field
      #
      # This function takes a Solr field, groups the articles of interest by
      # the values for the given field, and returns the result in a hash.
      #
      # @todo This function should support the same kind of work with names
      #   that we have in RLetters::Documents::Author.
      #
      # @return [Result] results of analysis
      def call
        Result.new(
          counts: normalize_counts(dataset ? group_dataset : group_corpus),
          normalize: normalize,
          normalization_dataset: normalization_dataset
        )
      end

      private

      # Walk a dataset manually and group it by field
      #
      # @return [Hash<String, Integer>] number of documents in each group
      def group_dataset
        ret = {}
        total = dataset.document_count

        enum = RLetters::Datasets::DocumentEnumerator.new(dataset: dataset)
        enum.each_with_index do |doc, i|
          key = get_field_from_document(doc)
          next if key.nil?

          ret[key] ||= 0
          ret[key] += 1

          progress&.call((i.to_f / total.to_f * 100.0).to_i)
        end

        progress&.call(100)
        ret
      end

      # Group the entire corpus by field, using Solr's result grouping
      #
      # @return [Hash<String, Integer>] number of documents in each group
      def group_corpus
        ret = {}
        start = 0

        num_docs = 0
        total_docs = RLetters::Solr::CorpusStats.new.size

        loop do
          search_result = RLetters::Solr::Connection.search_raw(
            q: '*:*',
            def_type: 'lucene',
            group: 'true',
            'group.field' => field.to_s,
            fl: 'uid',
            facet: 'false',
            start: start.to_s,
            rows: 100
          )

          # These conditions would indicate a malformed Solr response
          break unless search_result.dig('grouped', field.to_s, 'matches')

          grouped = search_result['grouped'][field.to_s]
          break if grouped['matches'].zero?

          groups = grouped['groups']
          break unless groups

          # This indicates that we're out of records
          break if groups.empty?

          # Add this batch to the return
          groups.each do |g|
            key = g['groupValue']
            val = g['doclist']['numFound']

            ret[key] = val

            # Update the progress meter
            if progress
              num_docs += g['doclist']['numFound']
              progress.call((num_docs.to_f / total_docs.to_f * 100.0).to_i)
            end
          end

          # Get the next batch of groups
          start += 100
        end

        progress&.call(100)
        ret
      end

      # Get the value of the field for grouping from a document
      #
      # This implements support for strange year values and grouping on the
      # facet field values. FIXME: This will probably do something very strange
      # if you try to count on :authors_facet.
      #
      # @param [Document] doc the Solr document
      # @return [String] the field value
      def get_field_from_document(doc)
        # Map the 'facet' fields to normal values
        return doc.journal if field == :journal_facet
        return doc.authors if field == :authors_facet

        # Support Y-M-D or Y/M/D dates, even though this field is supposed to
        # be only year values
        if field == :year
          return nil unless doc.year.present?

          parts = doc.year.split(%r{[-/]})
          year = parts[0]

          # Issues #108 and #109: make sure to exclude non-numerical year
          # values
          begin
            Integer(parts[0])
          rescue ArgumentError
            return nil
          end

          return year
        end

        # We're not yet actually faceting on anything other than journal,
        # author, or year; so this code isn't tested
        # :nocov:
        nil
        # :nocov:
      end

      # Fill in zeros for any missing values in the counts
      #
      # If field is year, we'll actually fill in the intervening years by
      # count. Otherwise, we'll just fill in any values that are present in
      # the normalization set but missing in the counts.
      #
      # @param [Hash<String, Numeric>] counts the counts queried
      # @param [Hash<String, Numeric>] normalization_counts the counts from the
      #   normalization set, nil if we didn't normalize
      # @return [Hash<String, Numeric>] the counts with intervening values set
      #   to zero
      def zero_intervening(counts, normalization_counts = nil)
        normalization_counts ||= {}

        if field == :year
          # Find the low and high values for the numerical contents here, if
          # asked to do so
          min = 99999
          max = -99999

          full_set = (counts.keys + normalization_counts.keys).compact
          full_set.each do |k|
            num = 0
            begin
              num = Integer(k)
            rescue ArgumentError
              next
            end

            min = num if num < min
            max = num if num > max
          end

          # Fill in all of the numerically intervening years
          Range.new(min, max).each do |i|
            counts[i.to_s] ||= 0.0
          end
        else
          normalization_counts.keys.compact.each do |k|
            counts[k] ||= 0.0
          end
        end

        counts
      end

      # Normalize the counts against the normalization set, if it exists
      #
      # This function also makes sure that the field values are a contiguous
      # range with no gaps, filling in zeros if necessary.
      #
      # @param [Hash<String, Integer>] counts the counts for the original set
      # @param [Hash<String, Float>] the normalized counts
      def normalize_counts(counts)
        return {} if counts.empty?
        return zero_intervening(counts) unless normalize

        norm_counts = CountArticlesByField.call(
          field: field,
          dataset: normalization_dataset
        ).counts

        ret = counts.each_with_object({}) do |(k, v), out|
          # Just don't save an entry for any really strange values here
          if k.present? && norm_counts[k]&.>(0)
            out[k] = v.to_f / norm_counts[k]
          end
        end

        zero_intervening(ret, norm_counts)
      end
    end
  end
end
