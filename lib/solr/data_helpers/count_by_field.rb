# -*- encoding : utf-8 -*-

module Solr
  module DataHelpers
    # Code for counting a dataset (or the corpus), grouped by a field
    module CountByField
      extend ActiveSupport::Concern

      module ClassMethods
        # Count up a dataset (or the corpus) by a field
        #
        # This function takes a dataset (or nil, to indicate the entire corpus) and
        # a Solr field, groups that set by the values for the given field, and
        # returns the counts in a hash.
        #
        # FIXME: This function should support the same kind of work with names
        # that we have in NameHelpers.
        #
        # @param [Dataset] dataset set to count, nil for the whole corpus
        # @param [Symbol] field field to group by
        # @return [Hash<String, Integer>] number of documents in each grouping
        # @example Group a dataset by year of publication
        #   Solr::DataHelpers.count_by_field(dataset, :year)
        #   # => { '1940' => 3, '1941' => 5, ... }
        def count_by_field(dataset, field)
          dataset ? group_dataset(dataset, field) : group_corpus(field)
        end

        private

        # Walk a dataset manually and group it by field
        #
        # @api private
        # @param [Dataset] dataset set to count
        # @param [Symbol] field field to group by
        # @return [Hash<String, Integer>] number of documents in each group
        def group_dataset(dataset, field)
          enum = RLetters::Datasets::DocumentEnumerator.new(dataset)
          enum.each_with_object({}) do |doc, ret|
            key = get_field_for_grouping(doc, field)
            ret[key] ||= 0
            ret[key] += 1
          end
        end

        # Group the entire corpus by field, using Solr's result grouping
        #
        # @api private
        # @param [Symbol] field field to group by
        # @return [Hash<String, Integer>] number of documents in each group
        def group_corpus(field)
          search_result = RLetters::Solr::Connection.search_raw({
            q: '*:*',
            def_type: 'lucene',
            group: 'true',
            'group.field' => field.to_s,
            fl: 'uid',
            facet: 'false'
          })

          unless search_result['grouped'] &&
                 search_result['grouped'][field.to_s] &&
                 search_result['grouped'][field.to_s]['matches']
            # :nocov:
            fail 'Solr server did not return any grouped results'
            # :nocov:
          end

          grouped = search_result['grouped'][field.to_s]
          return {} if grouped['matches'] == 0

          groups = grouped['groups']
          return {} unless groups

          groups.each_with_object({}) do |g, ret|
            key = g['groupValue']
            val = g['doclist']['numFound']

            ret[key] = val
          end
        end

        # Get the value of the field for grouping
        #
        # This implements support for strange year values.
        #
        # @api private
        # @param [Document] doc the Solr document
        # @param [Symbol] field the field for grouping
        # @return [String] the field value
        def get_field_for_grouping(doc, field)
          return doc.send(field) unless field == :year

          # Support Y-M-D or Y/M/D dates, even though this field is supposed to
          # be only year values
          parts = doc.year.split(/[-\/]/)
          parts[0]
        end
      end
    end
  end
end
