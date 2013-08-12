# -*- encoding : utf-8 -*-

module Jobs
  module Analysis

    # Plot a dataset's members by year
    class PlotDates < Jobs::Analysis::Base
      # Export the date format data
      #
      # Like all view/multiexport jobs, this job saves its data out as a YAML
      # file and then sends it to the user in various formats depending on
      # user selectons
      #
      # @api public
      # @return [undefined]
      # @example Start a job for plotting a dataset by year
      #   Delayed::Job.enqueue Jobs::Analysis::PlotDates.new(
      #     user_id: current_user.to_param,
      #     dataset_id: dataset.to_param)
      def perform
        # Fetch the user based on ID
        user = User.find(user_id)
        raise ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset = user.datasets.find(dataset_id)
        raise ArgumentError, 'Dataset ID is not valid' unless dataset

        # Make a new analysis task
        @task = dataset.analysis_tasks.create(name: 'Plot dataset by date',
                                              job_type: 'PlotDates')

        # Write out the dates to an array
        dates = []
        dataset.entries.find_in_batches do |group|
          # Build a Solr query to fetch only the year for this group
          solr_query = {}
          solr_query[:rows] = group.count
          query_str = group.map { |e| e.shasum }.join(' OR ')
          solr_query[:q] = "shasum:(#{query_str})"
          solr_query[:qt] = 'precise'
          solr_query[:fl] = 'year'
          solr_query[:facet] = false

          search_result = Solr::Connection.find solr_query
          raise StandardError, 'Failed to get batch of results in PlotDates' unless search_result.num_hits == group.count

          search_result.documents.each do |doc|
            # Support Y-M-D or Y/M/D dates
            parts = doc.year.split(/[-\/]/)
            year = Integer(parts[0])

            year_array = dates.assoc(year)
            if year_array
              year_array[1] = year_array[1] + 1
            else
              dates << [year, 1]
            end
          end
        end

        # Sort by date
        dates = dates.sort_by { |y| y[0] }

        # Serialize out to YAML
        @task.result_file = Download.create_file('dates.yml') do |file|
          file.write(dates.to_yaml)
          file.close
        end

        # Make sure the task is saved, setting 'finished_at'
        @task.finished_at = DateTime.current
        @task.save
      end

      # We don't want users to download the YAML file
      def self.download?
        false
      end
    end

  end
end
