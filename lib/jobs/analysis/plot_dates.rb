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
        fail ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset = user.datasets.find(dataset_id)
        fail ArgumentError, 'Dataset ID is not valid' unless dataset

        # Make a new analysis task
        @task = dataset.analysis_tasks.create(name: 'Plot dataset by date',
                                              job_type: 'PlotDates')

        # Write out the dates to an array
        dates = Solr::DataHelpers::count_by_field(dataset, :year).to_a
        dates.each { |d| d[0] = Integer(d[0]) }

        # Sort by date
        dates = dates.sort_by { |y| y[0] }

        # Serialize out to YAML
        @task.result_file = Download.create_file('dates.yml') do |file|
          file.write(dates.to_yaml)
          file.close
        end

        # We're done here
        @task.finish!
      end

      # We don't want users to download the YAML file
      def self.download?
        false
      end
    end

  end
end
