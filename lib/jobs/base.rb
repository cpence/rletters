# -*- encoding : utf-8 -*-

# Code that runs as delayed jobs
#
# This module contains classes for all code that runs as a delayed job.
#
# Some guidelines for RLetters delayed jobs:
# - These jobs should, except in rare cases (like +DestroyDataset+) only
#   query Solr or the SQL database for something like 1,000 rows at a time.
#   Forgetting to put bounds on queries could result in fetching hundreds of
#   thousands of records from the database, possibly freezing up the DJ
#   worker for a period of days.
# - All of these jobs should derive from +Jobs::Base+ to enable error handling
#   and easy attribute setting and comparison.
# - Analysis jobs should derive from +Jobs::AnalysisJob+ to get some common
#   attributes.
module Jobs

  # Base class for all delayed jobs
  class Base

    # Initialize the job from a hash of attributes in a generic way
    #
    # This constructor will simply set all of the passed +args+ as attribute
    # values, if the job has the given attribute.
    #
    # @api public
    # @param [Hash] args the instance variables to set
    # @return [undefined]
    # @example Setting attributes in a job class
    #   class TestJob < Jobs::Base
    #     attr_accessor :name
    #   end
    #   job = TestJob.new(name: 'Testing')
    #   job.name
    #   # => 'Testing'
    def initialize(args = { })
      @state_vars = args.keys

      args.each_pair do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
    end

    # Get a hash of attributes from the state variables
    #
    # @api semipublic
    # @return [Hash] hash of all attributes set on construction
    # @example Get the attributes of a job class
    #   class TestJob < Jobs::Base
    #     attr_accessor :name, :test
    #   end
    #   job = TestJob.new(name: 'Testing')
    #   job.test = 'woo'
    #   job.attributes
    #   # => { :name => 'Testing' }
    #   # Note: does NOT include :test, as this was not set on
    #   # construction
    def attributes
      ret = {}
      @state_vars.each { |k| ret[k] = instance_variable_get("@#{k.to_s}") }
      ret
    end

    # Compare objects for equality based on their attributes
    #
    # @api public
    # @return [Boolean] true if +self+ is equal to +other+
    def ==(other)
      attributes == other.attributes
    end
    alias_method :eql?, :==

    # Report any exceptions to Airbrake, if it's enabled
    #
    # This method is a callback that is invoked by Delayed::Job.  No tests, as
    # it's merely a wrapper on the Airbrake gem.
    #
    # @api private
    # @param [Delayed::Job] job The job currently being run
    # @param [StandardError] exception The exception raised to cause the error
    # @return [undefined]
    # :nocov:
    def error(job, exception)
      unless Setting.airbrake_key.blank?
        Airbrake.notify(exception)
      end
    end
    # :nocov:

    # Don't restart jobs on error
    #
    # Restarting isn't going to help resolve any errors that are presented, so
    # don't try it.
    #
    # @api private
    # @return [Integer] returns 1
    # :nocov:
    def max_attempts
      1
    end
    # :nocov:

  end

end
