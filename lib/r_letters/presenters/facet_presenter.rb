# frozen_string_literal: true

module RLetters
  module Presenters
    # Code for formatting attributes on a Facet object
    class FacetPresenter
      include Virtus.model(strict: true, required: true)
      attribute :facet, Solr::Facet

      # Get a human-readable version of the `value` attribute
      #
      # The facets for years are returned in Solr format, looking something
      # like `[1900 TO 1910]`. This function makes sure we convert from those
      # to a readable format for display
      #
      # @return [String] the `value` attribute, in human-readable form
      def label
        case facet.field
        when :authors_facet
          facet.value
        when :journal_facet
          facet.value
        when :year
          year_label
        else
          fail ArgumentError, "do not know how to handle facets on #{facet.field}"
        end
      end

      # Get a translated version of the `field` attribute
      #
      # @return [String] the `field` attribute, in human-readable form
      def field_label
        case facet.field
        when :authors_facet
          I18n.t('search.index.authors_facet_short')
        when :journal_facet
          I18n.t('search.index.journal_facet_short')
        when :year
          I18n.t('search.index.year_facet_short')
        else
          fail ArgumentError, "do not know how to handle facets on #{facet.field}"
        end
      end

      private

      # Format a label suitable for displaying a year facet
      #
      # @return [String] the human-readable form of a year facet query
      def year_label
        @year_label ||= begin
          # We need to parse the decade out of "[X TO Y]"
          value_without_brackets = facet.value[1..-2]

          parts = value_without_brackets.split
          fail ArgumentError, 'invalid year query' unless parts.size == 3

          decade = parts[0]
          decade = '1790' if decade == '*'
          decade = Integer(decade)

          if decade == 1790
            I18n.t('search.index.year_before_1800')
          elsif decade == 2010
            I18n.t('search.index.year_after_2010')
          else
            "#{decade}–#{decade + 9}"
          end
        end
      end
    end
  end
end
