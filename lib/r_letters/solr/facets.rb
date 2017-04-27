
module RLetters
  module Solr
    # The list of all facets returned by Solr
    #
    # @!attribute [r] all
    #   @return [Array<RLetters::Solr::Facet>] all the facet objects
    class Facets
      attr_reader :all

      # Create parameters for a link to search with the given set of facets
      #
      # All parameters other than `:fq` are simply duplicated (including the
      # search query itself, `:q`).
      #
      # @param [ActionController::Parameters] params the active parameters
      # @param [Array<Facet>] facets the facets to link to
      # @return [ActionController::Parameters] params for a search for these
      #   facets
      def self.search_params(params, facets)
        if facets.empty?
          return RLetters::Solr::Search::permit_params(params.except(:fq))
        end

        ret = params.except(:fq)
        ret[:fq] = facets.map(&:query)

        RLetters::Solr::Search::permit_params(ret)
      end

      # Return a list of facets that are active given these parameters
      #
      # @param [ActionController::Parameters] params the active parameters
      # @return [Array<Facet>] the active facets
      def active(params)
        return [] if blank? || !params[:fq]

        [].tap do |ret|
          [params[:fq]].flatten.each do |query|
            ret << for_query(query)
          end

          ret.compact!
        end
      end

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
              @all << Facet.new(field: f.name, value: it.value, hits: it.hits)
            end
          end
        end

        # Step through the facet queries
        return unless facet_queries
        facet_queries.each do |k, v|
          next if Integer(v) == 0
          @all << Facet.new(query: k, hits: v)
        end
      end
    end
  end
end
