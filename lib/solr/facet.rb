# -*- encoding : utf-8 -*-

# Code for parsing Solr's Ruby response format into a useful set of objects
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
  # @!attribute label
  #   @return [String] +value+ in human-readable form
  # @!attribute field_label
  #   @return [String] +field+ in human-readable form
  class Facet
    attr_accessor :query, :field, :value, :hits, :label, :field_label

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

        raise ArgumentError unless options[:hits]
        @hits = Integer(options[:hits])

        # Basic format: "field:QUERY"
        parts = @query.split(':')
        raise ArgumentError unless parts.count == 2

        @field = parts[0].to_sym
        @value = parts[1]

        # Strip quotes from the value if present
        @value = @value[1..-2] if @value[0] == '"' && @value[-1] == '"'

        # Format the label according to the field type -- for now, the only
        # argument type is year, so raise an error otherwise
        raise ArgumentError unless @field == :year
        format_year_label

        return
      end

      # We need to have name, value, and hits
      raise ArgumentError unless options[:name]
      @field = options[:name].to_sym

      raise ArgumentError unless options[:value]
      @value = options[:value]

      # Strip quotes from the value if present
      @value = @value[1..-2] if @value[0] == '"' && @value[-1] == '"'

      raise ArgumentError unless options[:hits]
      @hits = Integer(options[:hits])

      # Construct the query
      @query = "#{field.to_s}:\"#{value}\""

      # Format the label
      case @field
      when :authors_facet
        @label = @value
        @field_label = I18n.t('search.index.authors_facet_short')
      when :journal_facet
        @label = @value
        @field_label = I18n.t('search.index.journal_facet_short')
      else
        raise ArgumentError
      end
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

    private

    # Format a label suitable for displaying a year facet
    #
    # Requires @value to be set, and will set @label and @field_label.
    #
    # @api private
    def format_year_label
      # We need to parse the decade out of "[X TO Y]"
      value_without_brackets = @value[1..-2]

      parts = value_without_brackets.split
      raise ArgumentError unless parts.count == 3

      decade = parts[0]
      if decade == '*'
        decade = '1790'
      end
      decade = Integer(decade)

      if decade == 1790
        @label = I18n.t('search.index.year_before_1800')
      elsif decade == 2010
        @label = I18n.t('search.index.year_after_2010')
      else
        @label = "#{decade}–#{decade + 9}"
      end

      @field_label = I18n.t('search.index.year_facet_short')
    end
  end

end
