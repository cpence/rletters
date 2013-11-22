# -*- encoding : utf-8 -*-

module Solr

  # Methods that help us process inbound data from Solr
  #
  # A handful of operations are so commonly performed on a dataset that we
  # abstract them here to increase code reuse and give us an opportunity to
  # optimize our interactions with the Solr server.
  module DataHelpers

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
    def self.count_by_field(dataset, field)
      ret = {}

      if dataset
        # If there is a dataset here, then we have to just walk it and
        # group it by the provided field.

        dataset.entries.find_in_batches do |group|
          # Build a Solr query to fetch only the one field for this group
          solr_query = {}
          solr_query[:rows] = group.count
          query_str = group.map { |e| "\"#{e.uid}\"" }.join(' OR ')
          solr_query[:q] = "uid:(#{query_str})"
          solr_query[:defType] = 'lucene'
          solr_query[:fl] = field.to_s
          solr_query[:facet] = false

          search_result = Solr::Connection.search solr_query
          unless search_result.num_hits == group.count
            # :nocov:
            fail "Failed to get batch of results in count_by_field (wanted #{group.count} hits, got #{search_result.num_hits})"
            # :nocov:
          end

          search_result.documents.each do |doc|
            key = get_field_for_grouping(doc, field)
            ret[key] ||= 0
            ret[key] += 1
          end
        end
      else
        # If we're just normalizing against the corpus, then we need to use
        # Solr's result grouping.

        solr_query = {}
        solr_query[:q] = '*:*'
        solr_query[:defType] = 'lucene'
        solr_query[:group] = 'true'
        solr_query[:'group.field'] = field.to_s
        solr_query[:fl] = 'uid'
        solr_query[:facet] = false

        search_result = Solr::Connection.search_raw solr_query
        unless search_result['grouped']
          # :nocov:
          fail 'Solr server did not return any grouped results'
          # :nocov:
        end

        grouped = search_result['grouped'][field.to_s]
        unless grouped && grouped['matches']
          # :nocov:
          fail 'Solr server did not return grouped results for field'
          # :nocov:
        end
        return {} if grouped['matches'] == 0

        groups = grouped['groups']
        return {} unless groups

        groups.each do |g|
          key = g['groupValue']
          val = g['doclist']['numFound']

          ret[key] = val
        end
      end

      ret
    end

    private

    # Get the value of the field for grouping
    #
    # This implements support for strange year values.
    #
    # @api private
    # @param [Document] doc the Solr document
    # @param [Symbol] field the field for grouping
    # @return [String] the field value
    def self.get_field_for_grouping(doc, field)
      return doc.send(field) unless field == :year

      # Support Y-M-D or Y/M/D dates, even though this field is supposed to
      # be only year values
      parts = doc.year.split(/[-\/]/)
      parts[0]
    end
  end
end
