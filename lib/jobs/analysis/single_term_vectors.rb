# -*- encoding : utf-8 -*-
require 'csv'

module Jobs
  module Analysis
    
    # Write out the term vectors for a single document
    class SingleTermVectors < Jobs::Analysis::Base
      # Export the term vectors for a one-document dataset
      #
      # This job writes out the term vector array to YAML, and will
      # only run on a dataset containing a single document.
      #
      # @api public
      # @return [undefined]
      # @example Start a job for exporting term vectors
      #   Delayed::Job.enqueue Jobs::Analysis::SingleTermVectors.new(
      #     :user_id => current_user.to_param, 
      #     :dataset_id => dataset.to_param)
      def perform        
        # Fetch the user based on ID
        user = User.find(user_id)
        raise ArgumentError, 'User ID is not valid' unless user
      
        # Fetch the dataset based on ID
        dataset = user.datasets.find(dataset_id)
        raise ArgumentError, 'Dataset ID is not valid' unless dataset
        
        # Make sure the dataset has one entry (you shouldn't
        # be able to start this task unless that's true)
        raise ArgumentError, 'Dataset has too many entries' unless dataset.entries.count == 1
        
        # Make a new analysis task
        @task = dataset.analysis_tasks.create(:name => "Term frequency information", :job_type => 'SingleTermVectors')
        
        # Get the document
        doc = Document.find_with_fulltext dataset.entries[0].shasum
        
        # Get the term vectors
        term_vectors = doc.term_vectors
        raise ArgumentError, 'Document does not have any term vectors' unless term_vectors
        
        # Write them out
        @task.result_file = Download.create_file('single_term_vectors.yml') do |file|
          file.write(term_vectors.to_yaml)
          file.close
        end
        
        # Make sure the task is saved, setting 'finished_at'
        @task.finished_at = DateTime.current
        @task.save
      end
      
      # We don't want users to download the YAML file
      def self.download?; false ; end
    end
    
  end
end
