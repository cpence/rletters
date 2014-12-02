# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    # Produce a parallel word frequency list for a dataset
    class WordFrequency < Jobs::Analysis::CSVJob
      add_concern 'ComputeWordFrequencies'

      # Export the word frequency data.
      #
      # This saves its data out as a CSV file to be downloaded by the user
      # later.  As of yet, we don't offer display in the browser; I think this
      # data is so complex that you'll want to pull it up on a spreadsheet.
      #
      # Note that there are also parameters to be passed in to the
      # `ComputeWordFrequencies` concern; see that concern's documentation for
      # the specification of those arguments.
      #
      # @see Jobs::Analysis::Concerns::ComputeWordFrequencies
      #
      # @param [Hash] options parameters for this job
      # @option options [String] :user_id the user whose dataset we are to
      #   work on
      # @option options [String] :dataset_id the dataset to operate on
      # @option options [String] :task_id the analysis task we're working from
      # @see Jobs::Analysis::Concerns::ComputeWordFrequencies
      # @return [void]
      # @example Start a job for computing a dataset's word frequencies
      #   Jobs::Analysis::WordFrequency.create(user_id: current_user.to_param,
      #                                        dataset_id: dataset.to_param,
      #                                        task_id: task.to_param,
      #                                        [concern arguments])
      def perform
        at(0, 100, t('common.progress_initializing'))
        standard_options!

        # Do the analysis
        analyzer = compute_word_frequencies(
          @dataset,
          ->(p) { at(p, 100, t('.progress_calculating')) },
          options)
        corpus_size = RLetters::Solr::CorpusStats.new.size

        # Create some CSV
        at(100, 100, t('common.progress_finished'))
        write_csv_and_save(t('.csv_header', name: @dataset.name), '') do |csv|
          # Output the block data
          if analyzer.blocks.size > 1
            csv << [t('.each_block')]

            name_row = ['']
            header_row = ['']
            word_rows = []
            analyzer.word_list.each do |w|
              word_rows << [w]
            end
            types_row = [t('.types_header')]
            tokens_row = [t('.tokens_header')]
            ttr_row = [t('.ttr_header')]

            analyzer.blocks.each_with_index do |b, i|
              s = analyzer.block_stats[i]

              name_row << s[:name] << '' << '' << ''
              header_row << t('.freq_header') \
                         << t('.prop_header') \
                         << t('.tfidf_dataset_header') \
                         << t('.tfidf_corpus_header')

              word_rows.each do |r|
                word = r[0]
                r << (b[word] || 0).to_s
                r << ((b[word] || 0).to_f / s[:tokens].to_f).to_s

                r << Math.tfidf((b[word] || 0).to_f / s[:tokens].to_f,
                                analyzer.df_in_dataset[word],
                                @dataset.entries.size)
                if analyzer.df_in_corpus.present?
                  r << Math.tfidf((b[word] || 0).to_f / s[:tokens].to_f,
                                  analyzer.df_in_corpus[word],
                                  corpus_size)
                else
                  r << ''
                end
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
          csv << [t('.whole_dataset')]
          csv << ['', t('.freq_header'), t('.prop_header'),
                  t('.df_header'), t('.tfidf_corpus_header')]
          analyzer.word_list.each do |w|
            tf_in_dataset = analyzer.tf_in_dataset[w]
            r = [w,
                 tf_in_dataset.to_s,
                 (tf_in_dataset.to_f / analyzer.num_dataset_tokens).to_s]
            if analyzer.df_in_corpus.present?
              r << analyzer.df_in_corpus[w].to_s
              r << Math.tfidf(tf_in_dataset, analyzer.df_in_corpus[w],
                              corpus_size)
            else
              r << ''
              r << ''
            end
            csv << r
          end
          csv << [t('.types_header'), analyzer.num_dataset_types.to_s]
          csv << [t('.tokens_header'), analyzer.num_dataset_tokens.to_s]
          csv << [t('.ttr_header'), (analyzer.num_dataset_types.to_f /
                                     analyzer.num_dataset_tokens).to_s]
        end

        # We're done here
        @task.finish!

        completed
      end
    end
  end
end
