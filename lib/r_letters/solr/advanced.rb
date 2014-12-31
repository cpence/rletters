
module RLetters
  module Solr
    # Code for handling our advanced search support
    module Advanced
      # @return [Hash<String, Symbol>] a list of advanced search fields and
      #   their corresponding label strings
      def self.search_fields
        {
          Document.human_attribute_name(:fulltext) + ' ' +
            I18n.t('lib.solr.advanced.type_fuzzy') => :fulltext_fuzzy,
          Document.human_attribute_name(:fulltext) + ' ' +
            I18n.t('lib.solr.advanced.type_exact') => :fulltext_exact,
          Document.human_attribute_name(:title) + ' ' +
            I18n.t('lib.solr.advanced.type_fuzzy') => :title_fuzzy,
          Document.human_attribute_name(:title) + ' ' +
            I18n.t('lib.solr.advanced.type_exact') => :title_exact,
          Document.human_attribute_name(:authors) => :authors,
          Document.human_attribute_name(:journal) + ' ' +
            I18n.t('lib.solr.advanced.type_fuzzy') => :journal_fuzzy,
          Document.human_attribute_name(:journal) + ' ' +
            I18n.t('lib.solr.advanced.type_exact') => :journal_exact,
          I18n.t('lib.solr.advanced.year_ranges') => :year_ranges,
          Document.human_attribute_name(:volume) => :volume,
          Document.human_attribute_name(:number) => :number,
          Document.human_attribute_name(:pages) => :pages
        }
      end

      # Convert an advanced search field and value pair to a Solr query
      #
      # @param [String] field the advanced search field
      # @param [String] value the search string
      # @param [String] boolean the boolean to combine the next search with
      # @return [String] the Solr query to add to the array
      def self.query_for(field, value, boolean)
        field = parse_field(field)

        # Special handling for a few of these field types
        query = if field == 'authors'
          authors_query(value)
        elsif field == 'year'
          year_ranges_query(value)
        else
          "#{field}:\"#{value}\""
        end

        # The boolean connective
        boolean = if boolean == 'and'
          ' AND '
        elsif boolean == 'or'
          ' OR '
        else
          ''
        end

        query + boolean
      end

      private

      # Convert from a passed field parameter to a Solr field parameter
      #
      # @return [Symbol] the Solr field to search
      def self.parse_field(field)
        return 'year' if field == 'year_ranges'
        return field unless field.include?('_')

        data, type = field.split('_')
        if data == 'fulltext'
          return 'fulltext_search' if type == 'exact'
          return 'fulltext_stem'
        end

        return data if type == 'exact'
        return "#{data}_stem"
      end

      # Split and clean up the authors parameter
      #
      # Authors can be passed as a list and are expected to be joined as an
      # AND query. This also utilizes the Lucene name functions we've defined
      # elsewhere.
      #
      # @param [String] value the authors search string
      # @return [String] the Solr query for this list of authors
      def self.authors_query(value)
        authors = value.split(',').map do |a|
          RLetters::Documents::Author.new(a.strip).to_lucene
        end
        authors_str = authors.join(' AND ')

        "authors:(#{authors_str})"
      end

      # Get the query string matching the given array of year ranges.
      #
      # @param [String] year_ranges the list of year ranges
      # @return [String] query string for this set of year ranges
      def self.year_ranges_query(year_ranges)
        # Strip whitespace, split on commas
        ranges = year_ranges.gsub(/\s/, '').split(',')
        year_queries = []

        ranges.each do |r|
          if r.include? '-'
            range_years = r.split('-')
            next unless range_years.size == 2
            next if range_years[0].match(/\A\d+\z/).nil?
            next if range_years[1].match(/\A\d+\z/).nil?

            year_queries << "[#{range_years[0]} TO #{range_years[1]}]"
          else
            next if r.match(/\A\d+\z/).nil?

            year_queries << r
          end
        end

        return '' if year_queries.empty?
        "year:(#{year_queries.join(' OR ')})"
      end
    end
  end
end
