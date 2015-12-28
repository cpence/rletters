
module RLetters
  # Code that manages output and visualization for analysis tasks
  module Visualization
    # Mix-ins to facilitate saving data out to CSV files
    module CSV
      extend ActiveSupport::Concern

      # Write a CSV file with the given header and subheader text
      #
      # This function will yield the CSV object as a block so that more data
      # may be added.
      #
      # @param [String] header The header to write
      # @param [String] subheader The subheader to write (optional)
      # @return [String] The CSV file, as a string
      # @yield [csv] Yields a +CSV+ object to the block, for writing out
      #   the data
      # @yieldparam [CSV] csv The object to write data into
      def csv_with_header(header:, subheader: nil)
        ::CSV.generate do |csv|
          csv << [header]
          csv << [subheader] if subheader
          csv << ['']

          yield(csv)

          # Always end CSVs with a blank row
          csv << ['']
        end
      end

      # Write columns of data into a CSV file
      #
      # This function takes a set of data and a specifier for that data, and
      # writes it out into the CSV block specified.
      #
      # @param [CSV] csv The CSV object to write data into
      # @param [Enumerable] data The data object to iterate over
      # @param [Hash<String, Symbol>] data_spec The specification of how to
      #   read the data. This is a hash with strings as keys (one string per
      #   column of data, used as the column header) and symbols as values
      #   (which specify the method to call on each element of `data` to get
      #   the column value).
      # @return [void]
      def write_csv_data(csv:, data:, data_spec:)
        unless data.respond_to?(:each)
          fail ArgumentError, 'data object passed to write_data not enumerable'
        end

        csv << data_spec.keys
        data.each do |row|
          csv << data_spec.values.map { |sym| row.method(sym).call }
        end
      end
    end
  end
end
