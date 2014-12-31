
# Decorate a facet object
#
# This class adds methods to display links related to adding and removing
# a facet from search results.
class FacetDecorator < Draper::Decorator
  decorates RLetters::Solr::Facet
  delegate_all

  # Get a human-readable version of the `value` attribute
  #
  # The facets for years are returned in Solr format, looking something
  # like `[1900 TO 1910]`. This function makes sure we convert from those to
  # a readable format for display
  #
  # @return [String] the `value` attribute, in human-readable form
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

  # Get a translated version of the `field` attribute
  #
  # @return [String] the `field` attribute, in human-readable form
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
  # @return [String] the human-readable form of a year facet query
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
        I18n.t('search.index.year_before_1800')
      elsif decade == 2010
        I18n.t('search.index.year_after_2010')
      else
        "#{decade}–#{decade + 9}"
      end
    end
  end
end
