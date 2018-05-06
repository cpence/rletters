# frozen_string_literal: true

module RLetters
  module Presenters
    # Code for formatting attributes of a Datasets::Query object
    class QueryPresenter
      include Virtus.model(strict: true, required: true)
      attribute :query, ::Datasets::Query

      # Get a human-readable version of the faceted browsing parameters
      #
      # @return [Array<String>] an array of decorated facet strings
      def fq_string
        return nil unless query.fq.present?

        query.fq.map do |q|
          parts = q.split(':')
          unless parts.size == 2
            raise ArgumentError, 'facet query not separated by colon'
          end

          facet = RLetters::Solr::Facet.new(field: parts[0].to_sym,
                                            value: parts[1],
                                            query: q,
                                            hits: 0)
          presenter = FacetPresenter.new(facet: facet)
          "#{presenter.field_label}: #{presenter.label}"
        end
      end

      # Get a human-readable version of the search type
      #
      # @return [String] the `def_type` attribute, in human-readable form
      def def_type_string
        case query.def_type
        when 'dismax'
          I18n.t('datasets.show.normal_search')
        else
          I18n.t('datasets.show.advanced_search')
        end
      end
    end
  end
end
