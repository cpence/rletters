# -*- encoding : utf-8 -*-
require 'csv'

module Jobs
  module Analysis

    # Produce a parallel word frequency list for a dataset
    class WordFrequency < Jobs::Analysis::Base
      add_concern 'ComputeWordFrequencies'

      def perform
        # Fetch the user based on ID
        user = User.find(user_id)
        fail ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset = user.datasets.find(dataset_id)
        fail ArgumentError, 'Dataset ID is not valid' unless dataset

        # Make a new analysis task
        @task = dataset.analysis_tasks.create(name: 'Word frequency list',
                                              job_type: 'WordFrequency')

        # Do the analysis
        analyzer = compute_word_frequencies(dataset)

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

        @task.result_file = Download.create_file('frequency.csv') do |file|
          file.write(csv_string)
          file.close
        end

        # We're done here
        @task.finish!
      end
    end
  end
end

