# -*- encoding : utf-8 -*-

module RLetters
  module Solr
    # The list of all facets returned by Solr
    #
    # @!attribute [r] all
    #   @return [Array<RLetters::Solr::Facet>] all the facet objects
    class Facets
      include Draper::Decoratable

      attr_reader :all

      # Get all facets for a given field
      #
      # @param [Symbol] field the field to retrieve facets for
      # @return [Array<RLetters::Solr::Facet>] all facets for this field
      def for_field(field)
        @all.select { |f| f.field == field.to_sym }
      end

      # Get all facets for a given field, sorted
      #
      # @param [Symbol] field the field to retrieve sorted facets for
      # @return [Array<RLetters::Solr::Facet>] sorted facets for this field
      def sorted_for_field(field)
        for_field(field).sort
      end

      # Find a facet by its query parameter
      #
      # @param [String] query the query to search for
      # @return [RLetters::Solr::Facet] the facet for this query
      def for_query(query)
        all.find { |f| f.query == query }
      end

      # Return true if there are no facets
      #
      # @return [Boolean] true if +all.empty?+
      def empty?
        return true unless @all
        @all.empty?
      end

      # Initialize from the two facet parameters from RSolr::Ext
      #
      # @param [Array<RSolr::Ext::Facet>] facets the facet parameters
      # @param [Hash] facet_queries the facet queries
      def initialize(facets, facet_queries)
        @all = []

        # Step through the facets
        if facets
          facets.each do |f|
            f.items.each do |it|
              next if Integer(it.hits) == 0
              @all << Facet.new(name: f.name, value: it.value, hits: it.hits)
            end
          end
        end

        # Step through the facet queries
        if facet_queries
          facet_queries.each do |k, v|
            next if Integer(v) == 0
            @all << Facet.new(query: k, hits: v)
          end
        end
      end
    end
  end
end
