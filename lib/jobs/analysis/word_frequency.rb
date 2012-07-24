# -*- encoding : utf-8 -*-

module Jobs
  module Analysis
    
    # Produce a parallel word frequency list for a dataset
    class WordFrequency < Jobs::Analysis::Base

      # Block size for this dataset, in words
      #
      # If this attribute is zero, then we will read from +num_blocks+
      # instead.  Defaults to zero.
      attr_accessor :block_size

      # Split the dataset into how many blocks?
      #
      # If this attribute is zero, we will read from +block_size+ instead.
      # Defaults to zero.
      attr_accessor :num_blocks

      # Split blocks only within, or across documents?
      #
      # If this is set to true, then we will effectively concatenate all the
      # documents before splitting into blocks.  If false, we'll split blocks
      # on a per-document basis.  Defaults to true.
      attr_accessor :split_across

      # How many words in the list?
      #
      # If greater than the number of types in the dataset (or zero), then
      # return all the words.  Defaults to zero.
      attr_accessor :num_words

      def tfidf(tf, df, num_docs)
        tf * Math.log10(num_docs.to_f / df.to_f)
      end

      def perform
        # Fetch the user based on ID
        user = User.find(user_id)
        raise ArgumentError, 'User ID is not valid' unless user
      
        # Fetch the dataset based on ID
        dataset = user.datasets.find(dataset_id)
        raise ArgumentError, 'Dataset ID is not valid' unless dataset

        # Make a new analysis task
        @task = dataset.analysis_tasks.create(:name => "Word frequency list", :job_type => 'WordFrequency')
        
        # Perform the analysis
        analyzer = WordFrequencyAnalyzer.new(dataset,
                                             :block_size => @block_size,
                                             :num_blocks => @num_blocks,
                                             :num_words => @num_words,
                                             :split_across => @split_across)
        
        # Create some CSV
        csv_string = CSV.generate do |csv|
          csv << ["Word frequency information for dataset #{dataset.name}"]
          csv << [""]

          # Output the block data
          if analyzer.blocks.count > 1
            csv << ["Each block of document:"]

            name_row = [ "" ]
            header_row = [ "" ]
            word_rows = []
            analyzer.word_list.each do |w|
              word_rows << [ w ]
            end
            types_row = ["Number of types"]
            tokens_row = ["Number of tokens"]
            ttr_row = ["Type/token ratio"]
            
            analyzer.blocks.each_with_index do |b, i|
              s = analyzer.block_stats[i]

              name_row << s[:name] << "" << "" << ""
              header_row << "Frequency" << "Proportion" << "TF/IDF (vs. dataset)" << "TF/IDF (vs. corpus)"

              word_rows.each do |r|
                word = r[0]
                r << b[word].to_s
                r << (b[word].to_f / s[:tokens].to_f).to_s

                r << tfidf(b[word].to_f / s[:tokens].to_f,
                           analyzer.df_in_dataset[word], dataset.entries.count)
                r << tfidf(b[word].to_f / s[:tokens].to_f,
                           analyzer.df_in_corpus[word], analyzer.num_corpus_documents)
              end

              # Output the block stats at the end
              types_row << s[:types].to_s << "" << "" << ""
              tokens_row << s[:tokens].to_s << "" << "" << ""
              ttr_row << (s[:types].to_f / s[:tokens].to_f).to_s << "" << "" << ""
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
          csv << [""]
          csv << ["For the entire dataset:"]
          csv << ["", "Frequency", "Proportion", "TF/IDF (dataset vs. corpus)"]
          analyzer.word_list.each do |w|
            tf_in_dataset = analyzer.tf_in_dataset[w]
            csv << [w,
                    tf_in_dataset.to_s,
                    (tf_in_dataset.to_f / analyzer.num_dataset_tokens.to_f).to_s,
                    tfidf(tf_in_dataset, analyzer.df_in_corpus[w], analyzer.num_corpus_documents)]
          end
          csv << ["Number of types", analyzer.num_dataset_types.to_s]
          csv << ["Number of tokens", analyzer.num_dataset_tokens.to_s]
          csv << ["Type/token ratio", (analyzer.num_dataset_types.to_f / analyzer.num_dataset_tokens.to_f).to_s]
          csv << [""]
        end
        
        @task.result_file = Download.create_file('frequency.csv') do |file|
          file.write(csv_string)
          file.close
        end
        
        # Make sure the task is saved, setting 'finished_at'
        @task.finished_at = DateTime.current
        @task.save
      end
    end
  end
end

