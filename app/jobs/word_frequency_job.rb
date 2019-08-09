# frozen_string_literal: true

# Produce a parallel word frequency list for a dataset
class WordFrequencyJob < ApplicationJob
  include RLetters::Visualization::Csv

  queue_as :analysis

  # Returns true if this job can be started now
  #
  # @return [Boolean] true if this job is not disabled
  def self.available?
    !(ENV['WORD_FREQUENCY_JOB_DISABLED'] || 'false').to_boolean
  end

  # Export the word frequency data.
  #
  # This saves its data out as a CSV file to be downloaded by the user
  # later.  As of yet, we don't offer display in the browser; I think this
  # data is so complex that you'll want to pull it up on a spreadsheet.
  #
  # @param [Datasets::Task] task the task we're working from
  # @param [Hash] options parameters for this job
  # @return [void]
  def perform(task, options = {})
    standard_options(task, options)

    # Patch up the two strange arguments that don't come in the right format
    # from the web form
    options[:all] = true if options[:word_method] == 'all'
    options.delete(:stemming) if options[:stemming] == 'no'

    # Do the analysis
    analyzer = RLetters::Analysis::Frequency.call(
      options.merge(
        dataset: dataset,
        progress: ->(p) { task.at(p, 100, t('.progress_calculating')) }
      )
    )

    corpus_size = RLetters::Solr::CorpusStats.new.size
    dataset_size = dataset.document_count

    # Create some CSV
    csv_string = csv_with_header(header: t('.csv_header',
                                           name: dataset.name)) do |csv|
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
          header_row << t('.freq_header') << t('.prop_header')
          header_row << t('.tfidf_dataset_header')
          header_row << t('.tfidf_corpus_header')

          word_rows.each do |r|
            word = r[0]
            r << (b[word] || 0).to_s
            r << ((b[word] || 0).to_f / s[:tokens].to_f).to_s

            r << Math.tfidf((b[word] || 0).to_f / s[:tokens].to_f,
                            analyzer.df_in_dataset[word],
                            dataset_size)
            r << if analyzer.df_in_corpus.present?
                   Math.tfidf((b[word] || 0).to_f / s[:tokens].to_f,
                              analyzer.df_in_corpus[word],
                              corpus_size)
                 else
                   ''
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

    # Write out the CSV to a file
    task.files.create(description: 'Spreadsheet',
                      short_description: 'CSV', downloadable: true) do |f|
      f.from_string(csv_string, filename: 'results.csv',
                                content_type: 'text/csv')
    end

    # Save out JSON to make an interactive word cloud
    word_cloud_data = {
      word_cloud_words: analyzer.word_list.each_with_object({}) do |w, ret|
        ret[w] = analyzer.tf_in_dataset[w]
      end
    }

    task.files.create(description: 'JSON Data for Word Cloud',
                      short_description: 'JSON') do |f|
      f.from_string(word_cloud_data.to_json, filename: 'word_cloud.json',
                                             content_type: 'application/json')
    end

    task.mark_completed
  end
end
