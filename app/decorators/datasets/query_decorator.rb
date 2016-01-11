
module Datasets
  # Decorate a query object
  #
  # This class adds methods to display the faceted browsing parameters in a
  # user friendly way.
  class Datasets::QueryDecorator < Draper::Decorator
    decorates Datasets::Query
    delegate_all

    # Get a human-readable version of the faceted browsing parameters
    #
    # @return [Array<String>] an array of decorated facet strings
    def fq
      return nil unless object.fq.present?

      object.fq.map do |q|
        parts = q.split(':')
        unless parts.size == 2
          fail ArgumentError, 'facet query not separated by colon'
        end

        pseudo_facet = OpenStruct.new(field: parts[0].to_sym, value: parts[1])
        decorator = FacetDecorator.decorate(pseudo_facet)
        "#{decorator.field_label}: #{decorator.label}"
      end
    end

    # Get a human-readable version of the search type
    #
    # @return [String] the `def_type` attribute, in human-readable form
    def def_type
      case object.def_type
      when 'dismax'
        I18n.t('datasets.show.normal_search')
      else
        I18n.t('datasets.show.advanced_search')
      end
    end
  end
end
