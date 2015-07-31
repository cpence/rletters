require 'csv'

# Base code for all jobs that write code out to CSV
class CSVJob < BaseJob
  protected

  # Write out the results of a job as a CSV file
  #
  # This function writes a CSV header, yields out to a block to write the
  # data, and then saves the file. The two parameters let you override the
  # default header and subheader.
  #
  # @param [String] header The header to write. If not specified, defaults
  #   to +t('.header', name: dataset.name)+.
  # @param [String] subheader The subheader to write. If not specified,
  #   defaults to +t('.subheader')+.
  # @return [void]
  # @yield [csv] Yields a +CSV+ object to the block, for writing out
  #   the data
  # @yieldparam [CSV] csv The object to write data into
  def write_csv(header = nil, subheader = nil)
    CSV.generate do |csv|
      csv << [header || t('.header', name: dataset.name)]
      csv << [subheader || t('.subheader')]
      csv << ['']

      yield(csv)

      # Always end CSVs with a blank row
      csv << ['']
    end
  end

  # Write out the results of the job as a CSV file and save it
  #
  # This function calls +write_csv+ and then saves the result into the task
  # as its downloadable result file.
  #
  # @param [String] header The header to write. If not specified, defaults
  #   to +t('.header', name: dataset.name)+.
  # @param [String] subheader The subheader to write. If not specified,
  #   defaults to +t('.subheader')+.
  # @return [void]
  # @yield [csv] Yields a +CSV+ object to the block, for writing out
  #   the data
  # @yieldparam [CSV] csv The object to write data into
  def write_csv_and_complete(header = nil, subheader = nil)
    csv_string = write_csv(header, subheader) do |csv|
      yield(csv)
    end

    # Write out the CSV to a file
    ios = StringIO.new(csv_string)
    file = Paperclip.io_adapters.for(ios)
    file.original_filename = 'results.csv'
    file.content_type = 'text/csv'

    task.result = file
    task.mark_completed
  end
end
