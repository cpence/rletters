# -*- encoding : utf-8 -*-

module Jobs

  # Module containing all analysis jobs
  module Analysis

    # Base class for all analysis jobs
    #
    # Analysis jobs are required to implement one partial, and possibly a
    # second view, located at +lib/jobs/analysis/views/(job)/*.html.haml+:
    #
    # - +_start.html.haml+: This contains code for starting a job.  It will be
    #   placed inside a <ul> tag, and so should contain at least one list
    #   item.  Commonly, it will contain (i) a single list item for
    #   starting the job, (ii) multiple <li> tags for different ways of
    #   starting the job, or (iii) a nested <ul> that contains different
    #   ways of starting the job (which will be handled gracefully by
    #   jQuery Mobile).  Note that this should have at least one link to the
    #   appropriate invocation of +datasets#task_start+ to be useful.
    # - +results.html.haml+ (optional): Tasks may report their results in two
    #   different ways.  Some tasks (e.g., ExportCitations) just dump all of
    #   their results into a file (see +AnalysisTask#result_file+) for the
    #   user to download.  This is the default, for which +#download?+ returns
    #   +true+.  If +#download?+ is overridden to return +false+, then the
    #   job is expected to implement the +results+ view, which will show the
    #   user the results of the job in HTML form.  The standard way to do this
    #   is to write the job results out as JSON in +AnalysisTask#result_file+,
    #   and then to parse this JSON into HAML in the view.
    class Base
      # Return the name of this job
      #
      # @return [String] name of this job
      def self.job_name
        'Base (ERROR)'
      end

      # True if this job produces a download
      #
      # If true (default), then links to results of tasks will produce links to
      # download the result_file from that task.  If not, then the link to the
      # task results will point to the 'results' view for this job.  Override
      # this method to return false if you want to use the 'results' view.
      #
      # @api public
      # @return [Boolean] true if task produces a download, false otherwise
      # @example Get a link to the results of a task
      #   if task.job_class.download?
      #     link_to '', controller: 'datasets', action: 'task_download',
      #       id: dataset.to_param, task_id: task.to_param
      #   else
      #     link_to '', controller: 'datasets', action: 'task_view',
      #       id: dataset.to_param, task_id: task.to_param,
      #       view: 'results'
      #   end
      def self.download?
        true
      end

      # Get a list of all classes that are analysis jobs
      #
      # This method looks up all the defined job classes in +lib/jobs/analysis+
      # and returns them in a list so that we may loop over them (e.g., when
      # including all job-start markup).
      #
      # @api public
      # @return [Array<Class>] array of class objects
      # @example Render the 'start' view for all jobs
      #   Jobs::Analysis::Base.job_list.each do |klass|
      #     render template: klass.view_path('start'), ...
      #   end
      def self.job_list
        # Get all the classes defined in the Jobs::Analysis module
        analysis_files = Dir[Rails.root.join('lib',
                                             'jobs',
                                             'analysis',
                                             '*.rb')]
        classes = analysis_files.map do |f|
          next if File.basename(f) == 'base.rb'

          # This will raise a NameError if the class doesn't exist, but we want
          # that, because that means there's a file in lib/jobs/analysis that
          # doesn't respect Rails' naming conventions.
          ('Jobs::Analysis::' + File.basename(f, '.rb').camelize).constantize
        end
        classes.compact!

        # Make sure that worked
        classes.each do |c|
          return [] unless c.is_a?(Class)
        end

        classes
      end

      # Add a concern to this job class
      #
      # Concerns are bundles of job code and views that can be mixed into
      # different analysis job tasks.  This is intended to support pieces of
      # functionality that will be shared across many different job types.
      #
      # @api public
      # @param [String] concern the concern to mix in
      # @return [undefined]
      # @example Mix the 'Normalization' concern into this job class
      #   class MyJob < Jobs::Analysis::Base
      #     add_concern 'Normalization'
      #     # ...
      #   end
      def self.add_concern(concern)
        # Protect against calling this more than once, though that would be
        # really daft
        if concerns && concerns.include?(concern)
          fail ArgumentError, "#{concern} has already been included in #{name}"
        end

        # We want this to throw a NameError if it doesn't work; this would be
        # a programmer's mistake
        klass = ('Jobs::Analysis::Concerns::' + concern).constantize
        include klass

        # Add it to the tracking list so that we'll pick up its views
        self.concerns ||= []
        self.concerns << concern
      end

      # Get the list of paths for this class's job views
      #
      # We let analysis jobs ship their own job view templates. This function
      # returns the name of that directory to be prepended into the Rails
      # view search path.
      #
      # When a job mixes in a concern, this method also supports the addition
      # of concern views.
      #
      # @api public
      # @return [Array<String>] the template directories to be added
      # @example Get the path to the ExportCitations views
      #   Jobs::Analysis::ExportCitations.view_paths
      #   # => ['#{Rails.root}/lib/jobs/analysis/views/export_citations']
      def self.view_paths
        # This turns 'Jobs::Analysis::ExportCitations' into 'export_citations'
        class_name = name.demodulize.underscore
        ret = [Rails.root.join('lib', 'jobs', 'analysis', 'views', class_name)]

        if @concerns
          @concerns.each do |c|
            ret << Rails.root.join('lib', 'jobs', 'analysis', 'concerns',
                                   'views', c.underscore)
          end
        end

        ret
      end

      private

      class << self
        # @return [Array<String>] the concerns mixed into this job class
        attr_accessor :concerns
      end
    end

  end
end
