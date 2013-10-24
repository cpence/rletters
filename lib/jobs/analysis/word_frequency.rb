# -*- encoding : utf-8 -*-
require 'csv'

module Jobs
  module Analysis

    # Produce a parallel word frequency list for a dataset
    class WordFrequency < Jobs::Analysis::Base
      add_concern 'ComputeWordFrequencies'
      @queue = 'analysis'

      # Returns true if this job can be started now
      #
      # @return [Boolean] true
      def self.available?
        true
      end

      # Return how many datasets this job requires
      #
      # @return [Integer] number of datasets needed to perform this job
      def self.num_datasets
        1
      end

      # Export the word frequency data.
      #
      # This saves its data out as a CSV file to be downloaded by the user
      # later.  As of yet, we don't offer display in the browser; I think this
      # data is so complex that you'll want to pull it up on a spreadsheet.
      #
      # Note that there are also parameters to be passed in to the
      # +ComputeWordFrequencies+ concern; see that concern's documentation for
      # the specification of those arguments.
      #
      # @param [Hash] args parameters for this job
      # @option args [String] user_id the user whose dataset we are to work on
      # @option args [String] dataset_id the dataset to operate on
      # @option args [String] task_id the analysis task we're working from
      # @see Jobs::Analysis::Concerns::ComputeWordFrequencies
      # @return [undefined]
      # @example Start a job for computing a dataset's word frequencies
      #   Resque.enqueue(Jobs::Analysis::WordFrequency,
      #                  user_id: current_user.to_param,
      #                  dataset_id: dataset.to_param,
      #                  task_id: task.to_param,
      #                  [word frequency concern arguments])
      def self.perform(args = { })
        args.symbolize_keys!

        # Fetch the user based on ID
        user = User.find(args[:user_id])
        fail ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset = user.datasets.find(args[:dataset_id])
        fail ArgumentError, 'Dataset ID is not valid' unless dataset

        # Update the analysis task
        task = dataset.analysis_tasks.find(args[:task_id])
        fail ArgumentError, 'Task ID is not valid' unless task

        task.name = 'Calculate word frequencies'
        task.save

        # Do the analysis
        analyzer = compute_word_frequencies(dataset, args)

        # Create some CSV
        csv_string = CSV.generate do |csv|
          csv << ["Word frequency information for dataset #{dataset.name}"]
          csv << ['']

          # Output the block data
          if analyzer.blocks.count > 1
            csv << ['Each block of document:']

            name_row = ['']
            header_row = ['']
            word_rows = []
            analyzer.word_list.each do |w|
              word_rows << [w]
            end
            types_row = ['Number of types']
            tokens_row = ['Number of tokens']
            ttr_row = ['Type/token ratio']

            analyzer.blocks.each_with_index do |b, i|
              s = analyzer.block_stats[i]

              name_row << s[:name] << '' << '' << ''
              header_row << 'Frequency' \
                         << 'Proportion' \
                         << 'TF/IDF (vs. dataset)' \
                         << 'TF/IDF (vs. corpus)'

              word_rows.each do |r|
                word = r[0]
                r << b[word].to_s
                r << (b[word].to_f / s[:tokens].to_f).to_s

                r << Math.tfidf(b[word].to_f / s[:tokens].to_f,
                                analyzer.df_in_dataset[word],
                                dataset.entries.count)
                r << Math.tfidf(b[word].to_f / s[:tokens].to_f,
                                analyzer.df_in_corpus[word],
                                analyzer.num_corpus_documents)
              end

              # Output the block stats at the end
              types_row << s[:types].to_s << '' << '' << ''
              tokens_row << s[:tokens].to_s << '' << '' << ''
              ttr_row << (s[:types].to_f / s[:tokens].to_f).to_s << '' << '' << ''
            end

            csv << name_row
            csv << header_row
            word_rows.each do |r|
              csv << r
            end
            csv << types_row
            csv << tokens_row
            csv << ttr_row
          end

          # Output the dataset data
          csv << ['']
          csv << ['For the entire dataset:']
          csv << ['', 'Frequency', 'Proportion', 'DF (in corpus)', 'TF/IDF (dataset vs. corpus)']
          analyzer.word_list.each do |w|
            tf_in_dataset = analyzer.tf_in_dataset[w]
            csv << [w,
                    tf_in_dataset.to_s,
                    (tf_in_dataset.to_f / analyzer.num_dataset_tokens.to_f).to_s,
                    analyzer.df_in_corpus[w].to_s,
                    Math.tfidf(tf_in_dataset, analyzer.df_in_corpus[w], analyzer.num_corpus_documents)]
          end
          csv << ['Number of types', analyzer.num_dataset_types.to_s]
          csv << ['Number of tokens', analyzer.num_dataset_tokens.to_s]
          csv << ['Type/token ratio', (analyzer.num_dataset_types.to_f / analyzer.num_dataset_tokens.to_f).to_s]
          csv << ['']
        end

        # Write it out
        ios = StringIO.new
        ios.write(csv_string)
        ios.original_filename = 'word_frequency.csv'
        ios.content_type = 'text/csv'
        ios.rewind

        task.result = ios
        ios.close

        # We're done here
        task.finish!
      end
    end
  end
end

