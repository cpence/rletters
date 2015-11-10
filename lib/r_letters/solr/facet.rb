
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
      include Virtus.model(strict: true, required: false)
      include VirtusExt::Validator
      include Draper::Decoratable
      include Comparable

      attribute :query, String
      attribute :field, Symbol
      attribute :value, String
      attribute :hits, Integer, required: true

      # Compare facet objects appropriately given their field
      #
      # In general, this sorts first by count and then by value.
      #
      # @param [Facet] other object for comparison
      # @return [Integer] -1, 0, or 1, appropriately
      def <=>(other)
        return -(hits <=> other.hits) if hits != other.hits

        # We want years to sort inverse, while we want others normal.
        return -(value <=> other.value) if field == :year
        (value <=> other.value)
      end

      private

      # Make sure that the options are consistent
      #
      # @return [void]
      def validate!
        if query.present?
          # Construct field and value from the query
          parts = query.split(':')
          unless parts.size == 2
            fail ArgumentError, 'facet query not separated by colon'
          end

          self.field = parts[0].to_sym
          self.value = parts[1]

          # Strip quotes from the value if present
          self.value = value[1..-2] if value[0] == '"' && value[-1] == '"'

          # We only know how to handle one field, year
          unless field == :year
            fail ArgumentError, "do not know how to handle facet queries for #{field}"
          end
        else
          fail ArgumentError, 'facet without field' if field.blank?
          fail ArgumentError, 'facet without value' if value.blank?

          # We only know how to handle :authors_facet and :journal_facet
          unless [:authors_facet, :journal_facet].include?(field)
            fail ArgumentError, "do not know how to handle facets on #{field}"
          end

          # Strip quotes from the value if present
          self.value = value[1..-2] if value[0] == '"' && value[-1] == '"'

          # Construct the query from field and value
          self.query = "#{field}:\"#{value}\""
        end
      end
    end
  end
end
