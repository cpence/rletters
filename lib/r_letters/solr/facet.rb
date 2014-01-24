# -*- encoding : utf-8 -*-

module RLetters
  module Solr
    # A representation of a Solr facet
    #
    # Solr facets arrive in a variety of formats, and thus have to be parsed in
    # a variety of ways.  This class attempts to handle all of that in the most
    # generic and extensible way possible.
    #
    # @!attribute query
    #   @return [String] the Solr filter query for this facet
    # @!attribute field
    #   @return [Symbol] the field that we are faceting on
    # @!attribute value
    #   @return [String] the value for this facet
    # @!attribute hits
    #   @return [Integer] the number of hits for this facet
    class Facet
      attr_accessor :query, :field, :value, :hits

      # Create a new facet
      #
      # We can either get a string-format query, or (from RSolr::Ext) a facet
      # object and an item object.  This handles dealing with all of that.  We
      # will get either +:name+, +:value+, and +:hits+ (a facet parameter), or
      # +:query+ and +:hits+ (a facet query).
      #
      # @param [Hash] options specification of the new facet
      # @option options [Symbol] :name The field being faceted on
      # @option options [String] :value The facet value
      # @option options [Integer] :hits Number of hits for this facet
      # @option options [String] :query Facet as a string query
      def initialize(options = {})
        if options[:query]
          # We already have a query here, so go ahead and save the query
          @query = options[:query]

          unless options[:hits]
            fail ArgumentError, 'facet query specified without hits'
          end

          @hits = Integer(options[:hits])

          # Basic format: "field:QUERY"
          parts = @query.split(':')
          unless parts.count == 2
            fail ArgumentError, 'facet query not separated by colon'
          end

          @field = parts[0].to_sym
          @value = parts[1]

          # We only know how to handle one field, year
          unless @field == :year
            fail ArgumentError, "do not know how to handle facet queries for #{@field}"
          end

          # Strip quotes from the value if present
          @value = @value[1..-2] if @value[0] == '"' && @value[-1] == '"'

          return
        end

        # We need to have name, value, and hits
        fail ArgumentError, 'facet without name' unless options[:name]
        @field = options[:name].to_sym

        # We only know how to handle :authors_facet and :journal_facet
        unless [:authors_facet, :journal_facet].include?(@field)
          fail ArgumentError, "do not know how to handle facets on #{@field}"
        end

        fail ArgumentError, 'facet without value' unless options[:value]
        @value = options[:value]

        # Strip quotes from the value if present
        @value = @value[1..-2] if @value[0] == '"' && @value[-1] == '"'

        fail ArgumentError, 'facet without hits' unless options[:hits]
        @hits = Integer(options[:hits])

        # Construct the query
        @query = "#{field.to_s}:\"#{value}\""
      end

      include Comparable

      # Compare facet objects appropriately given their field
      #
      # In general, this sorts first by count and then by value.
      #
      # @param [Facet] other object for comparison
      # @return [Integer] -1, 0, or 1, appropriately
      def <=>(other)
        return -(@hits <=> other.hits) if hits != other.hits

        # We want years to sort inverse, while we want others normal.
        return -(@value <=> other.value) if field == :year
        (@value <=> other.value)
      end
    end
  end
end
