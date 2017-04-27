
module RLetters
  module Solr
    # Code to process search parameters inbound from the search page and API
    module Search
      # Sanitize the parameters that should be passed through the controller
      def self.permit_params(params)
        params.permit(# Rails' default parameters
                      :controller, :action,
                      # Basic search parameters
                      :q, :advanced, :page, :per_page, :cursor_mark, :sort,
                      # Advanced search parameters
                      :field_0, :field_1, :field_2, :field_3, :field_4,
                      :field_5, :field_6, :field_7, :field_8, :field_9,
                      :field_10, :field_11, :field_12, :field_13, :field_14,
                      :field_15, :field_16, :value_0, :value_1, :value_2,
                      :value_3, :value_4, :value_5, :value_6, :value_7,
                      :value_8, :value_9, :value_10, :value_11, :value_12,
                      :value_13, :value_14, :value_15, :value_16, :boolean_0,
                      :boolean_1, :boolean_2, :boolean_3, :boolean_4,
                      :boolean_5, :boolean_6, :boolean_7, :boolean_8,
                      :boolean_9, :boolean_10, :boolean_11, :boolean_12,
                      :boolean_13, :boolean_14, :boolean_15, :boolean_16,
                      # Array form filter parameters
                      fq: [], categories: [])
      end

      # Convert the parameters from the SearchController to a Solr query
      #
      # @param [Hash] params the params from the controller
      # @param [Boolean] api if true, this is an API query, not a standard
      #   HTML search query
      # @return [Hash] the Solr query to execute based on these parameters
      def self.params_to_query(params, api = false)
        # Remove any blank values (you get these on form submissions, for
        # example)
        params.delete_if { |_, v| v.blank? }

        parse_position(params, api)
          .merge(parse_facets_and_categories(params))
          .merge(parse_search(params))
      end

      private

      # Parse the sort, start, and rows values
      #
      # @param [Hash] params the params from the controller
      # @param [Boolean] api if true, this is an API query, not a standard
      #   HTML search query
      # @return [Hash] a hash with `:sort`, `:start`, and `:rows` set
      def self.parse_position(params, api)
        {}.tap do |ret|
          # Default sort to relevance if there's a search, otherwise year; also
          # let the params override this if there is a sort specified in the
          # query
          if params[:advanced] || params[:q]
            ret[:sort] = 'score desc'
          else
            ret[:sort] = 'year_sort desc'
          end
          ret[:sort] = params[:sort] if params[:sort].present?

          # If this is an API search, they are allowed to set page and per_page
          # to control the start and rows values; otherwise we are using cursor
          # support
          if api
            page = (params[:page]&.to_i || 0).lbound(0)
            per_page = (params[:per_page]&.to_i || 10).bound(10, 100)

            ret[:start] = page * per_page
            ret[:rows] = per_page
          else
            # We must always include uid in the sort string to use cursor
            # support
            ret[:sort] << ',uid asc'
            ret[:cursor_mark] = params[:cursor_mark] || '*'
            ret[:rows] = 16
          end
        end
      end

      # Parse the faceted browsing and category parameters
      #
      # @param [Hash] params the params from the controller
      # @return [Hash] a hash with `:fq` set
      def self.parse_facets_and_categories(params)
        {}.tap do |ret|
          # Initialize by copying over the faceted-browsing query
          ret[:fq] = params[:fq] if params[:fq].present?

          # And converting categories to facets
          if params[:categories]
            category_journals = params[:categories].collect do |id|
              category = ::Documents::Category.find(id)
              next if category.journals.empty?

              category.journals.map { |j| "\"#{j}\"" }
            end
            category_journals.compact!&.uniq!

            unless category_journals.empty?
              ret[:fq] ||= []
              ret[:fq] << "journal_facet:(#{category_journals.join(' OR ')})"
            end
          end
        end
      end

      # Parse the actual search parameters
      #
      # @param [Hash] params the params from the controller
      # @return [Hash] a hash with `:q` and `:def_type` set
      def self.parse_search(params)
        {}.tap do |ret|
          # Advanced search support
          if params[:advanced]
            q_array = []

            # Advanced search, step through the fields
            ret[:def_type] = 'lucene'

            # Copy the basic query across
            q_array << "#{params[:q]} AND " if params[:q].present?

            # Hard-coded limit of 16 on the number of advanced queries
            0.upto(16) do |i|
              field = params["field_#{i}".to_sym]
              value = params["value_#{i}".to_sym]
              boolean = params["boolean_#{i}".to_sym]
              break if field.nil? || value.nil?

              q_array << Advanced.query_for(field, value, boolean)
            end

            # Prune any empty/nil (invalid) queries
            q_array.delete_if(&:blank?)

            # If there's no query after that, add the all-documents operator
            if q_array.empty?
              ret[:q] = '*:*'
            else
              # Remove the last trailing boolean connective
              ret[:q] = q_array.join.chomp(' OR ').chomp(' AND ')
            end
          else
            # Simple search
            if params[:q]
              ret[:q] = params[:q]
              ret[:def_type] = 'dismax'
            else
              ret[:q] = '*:*'
              ret[:def_type] = 'lucene'
            end
          end
        end
      end
    end
  end
end
