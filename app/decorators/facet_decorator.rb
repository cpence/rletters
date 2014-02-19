# -*- encoding : utf-8 -*-

class FacetDecorator < Draper::Decorator
  decorates RLetters::Solr::Facet
  delegate_all

  # @return [String] the +value+ attribute, in human-readable form
  def label
    case field
    when :authors_facet
      value
    when :journal_facet
      value
    when :year
      year_label
    else
      fail ArgumentError, "do not know how to handle facets on #{field}"
    end
  end

  # @return [String] the +field+ attribute, in human-readable form
  def field_label
    case field
    when :authors_facet
      I18n.t('search.index.authors_facet_short')
    when :journal_facet
      I18n.t('search.index.journal_facet_short')
    when :year
      I18n.t('search.index.year_facet_short')
    else
      fail ArgumentError, "do not know how to handle facets on #{field}"
    end
  end

  private

  # Format a label suitable for displaying a year facet
  #
  # Requires @value to be set, and will set @label and @field_label.
  #
  # @api private
  def year_label
    @year_label ||= begin
      # We need to parse the decade out of "[X TO Y]"
      value_without_brackets = value[1..-2]

      parts = value_without_brackets.split
      fail ArgumentError, 'invalid year query' unless parts.size == 3

      decade = parts[0]
      decade = '1790' if decade == '*'
      decade = Integer(decade)

      if decade == 1790
        label = I18n.t('search.index.year_before_1800')
      elsif decade == 2010
        label = I18n.t('search.index.year_after_2010')
      else
        label = "#{decade}–#{decade + 9}"
      end
    end
  end
end
