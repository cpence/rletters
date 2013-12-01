# -*- encoding : utf-8 -*-

module Jobs
  module Analysis

    # Determine statistically significant collocations in text
    class Collocation < Jobs::Analysis::Base
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

      # Locate significant associations between words.
      #
      # This saves its data out as a CSV file to be downloaded by the user
      # later.
      #
      # @param [Hash] args parameters for this job
      # @option args [String] user_id the user whose dataset we are to work on
      # @option args [String] dataset_id the dataset to operate on
      # @option args [String] task_id the analysis task we're working from
      # @option args [String] analysis_type the algorithm to use to analyze the
      #   significance of collocations.  Can be 'mi' (for mutual
      #   information), 't' (for t-test), 'likelihood' (for log-likelihood),
      #   or 'pos' (for part-of-speech biased frequencies).
      # @option args [Integer] num_pairs number of collocations to return
      # @return [undefined]
      # @example Start a job for comparing two datasets
      #   Resque.enqueue(Jobs::Analysis::Collocation,
      #                  user_id: current_user.to_param,
      #                  dataset_id: dataset.to_param,
      #                  task_id: task.to_param,
      #                  num_pairs: 50)
      def self.perform(args = { })
        args.symbolize_keys!

        # Fetch the user based on ID
        user = User.find(args[:user_id])
        fail ArgumentError, 'User ID is not valid' unless user

        # Fetch the dataset based on ID
        dataset = user.datasets.active.find(args[:dataset_id])
        fail ArgumentError, 'Dataset ID is not valid' unless dataset

        # Update the analysis task
        task = dataset.analysis_tasks.find(args[:task_id])
        fail ArgumentError, 'Task ID is not valid' unless task

        task.name = I18n.t('jobs.analysis.collocation.short_desc')
        task.save

        analysis_type = (args[:analysis_type] || :mi).to_sym
        num_pairs = (args[:num_pairs] || 50).to_i

        # Part of speech tagging requires the Stanford NLP
        analysis_type = :mi if !NLP_ENABLED && analysis_type == :pos

        case analysis_type
        when :mi
          algorithm = I18n.t('jobs.analysis.collocation.mi')
          column = I18n.t('jobs.analysis.collocation.mi_column')
          grams = analyze_mutual_information(dataset)
        when :t
          algorithm = I18n.t('jobs.analysis.collocation.t')
          column = I18n.t('jobs.analysis.collocation.t_column')
          grams = analyze_t_test(dataset)
        when :likelihood
          algorithm = I18n.t('jobs.analysis.collocation.likelihood')
          column = I18n.t('jobs.analysis.collocation.likelihood_column')
          grams = analyze_likelihood(dataset)
        when :pos
          # :nocov:
          algorithm = I18n.t('jobs.analysis.collocation.pos')
          column = I18n.t('jobs.analysis.collocation.pos_column')
          grams = analyze_pos(dataset)
          # :nocov:
        else
          fail ArgumentError, 'Invalid value for analysis_type'
        end

        grams = grams.to_a.sort_by(&:last).reverse_each.take(num_pairs)

        # Save out all the data
        data = {
          name: dataset.name,
          algorithm: algorithm,
          column: column,
          data: grams
        }

        # Write it out
        ios = StringIO.new
        ios.write(data.to_json)
        ios.original_filename = 'collocation.json'
        ios.content_type = 'application/json'
        ios.rewind

        task.result = ios
        ios.close

        # We're done here
        task.finish!
      end

      # We don't want users to download the JSON file
      def self.download?
        false
      end

      # Helper method for creating the job parameters view
      #
      # This method returns the list of available significance test methods.
      def self.significance_tests
        [:mi, :t, :likelihood, :pos].map do |sym|
          [I18n.t("jobs.analysis.collocation.#{sym}"), sym]
        end
      end

      private

      def self.analyze_mutual_information(dataset)
        # MUTUAL INFORMATION
        # PMI(a, b) = log [ (f(a b) / N) / (f(a) f(b) / N^2) ]
        # with N the number of single-word tokens

        bigrams = compute_word_frequencies(dataset, ngrams: 2,
                                                    num_blocks: 1,
                                                    split_across: true)
        words = compute_word_frequencies(dataset, num_blocks: 1,
                                                  split_across: true)

        bigram_f = bigrams.blocks[0]
        word_f = words.blocks[0]
        n = words.num_dataset_tokens.to_f
        n_2 = n * n

        Hash[bigram_f.map do |b|
          bigram_words = b[0].split
          [b[0],
           Math.log((b[1].to_f / n) /
                    (word_f[bigram_words[0]].to_f * word_f[bigram_words[1]] / n_2))]
        end]
      end

      def self.analyze_t_test(dataset)
        # T-TEST
        # Pr(a) = f(a) / N
        # Pr(b) = f(b) / N
        # H0 = independent occurrences A and B = Pr(a) * Pr(b)
        # x = f(a b) / N
        # s^2 = H0 * (1 - H0)
        # t = (x - H0) / sqrt(s^2 / N)
        # convert t to a p-value based on N
        #   1 - Distribution::T.cdf(t, N-1)

        bigrams = compute_word_frequencies(dataset, ngrams: 2,
                                                    num_blocks: 1,
                                                    split_across: true)
        words = compute_word_frequencies(dataset, num_blocks: 1,
                                                  split_across: true)

        bigram_f = bigrams.blocks[0]
        word_f = words.blocks[0]
        n = words.num_dataset_tokens.to_f

        Hash[bigram_f.map do |b|
          bigram_words = b[0].split
          h_0 = (word_f[bigram_words[0]].to_f / n) *
                (word_f[bigram_words[1]].to_f / n)
          t = ((b[1].to_f / n) - h_0) / Math.sqrt((h_0 * (1.0 - h_0)) / n)

          [b[0], 1.0 - Distribution::T.cdf(t, n - 1)]
        end]
      end

      def self.log_l(k, n, x)
        # L(k, n, x) = x^k (1 - x)^(n - k)
        Math.log(x**k * ((1 - x)**(n - k)))
      end

      def self.analyze_likelihood(dataset)
        # LIKELIHOOD RATIO
        # Log-lambda = log L(f(a b), f(a), f(a) / N) +
        #              log L(f(b) - f(a b), N - f(a), f(a) / N) -
        #              log L(f(a b), f(a), f(a b) / f(a)) -
        #              log L(f(b) - f(a b), N - f(a), (f(b) - f(a b)) / (N - f(a)))
        # sort by -2 log-lambda

        bigrams = compute_word_frequencies(dataset, ngrams: 2,
                                                    num_blocks: 1,
                                                    split_across: true)
        words = compute_word_frequencies(dataset, num_blocks: 1,
                                                  split_across: true)

        bigram_f = bigrams.blocks[0]
        word_f = words.blocks[0]
        n = words.num_dataset_tokens.to_f

        Hash[bigram_f.map do |b|
          bigram_words = b[0].split
          f_ab = b[1].to_f
          f_a = word_f[bigram_words[0]].to_f
          f_b = word_f[bigram_words[1]].to_f

          ll = log_l(f_ab, f_a, f_a / n) +
               log_l(f_b - f_ab, n - f_a, f_a / n) -
               log_l(f_ab, f_a, f_ab / f_a) -
               log_l(f_b - f_ab, n - f_a, (f_b - f_ab) / (n - f_a))
          [b[0], -2.0 * ll]
        end]
      end

      # No coverage here, as we don't install Stanford NLP on Travis
      # :nocov:

      POS_BI_REGEXES = [
        /[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # ADJ NOUN
        /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/ # NOUN NOUN
      ]
      POS_TRI_REGEXES = [
        /[^\s]+_JJ[^\s]?\s+[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # ADJ ADJ NOUN
        /[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/, # ADJ NOUN NOUN
        /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_JJ[^\s]?\s+[^\s]+_NN[^\s]{0,2}/, # NOUN ADJ NOUN
        /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}\s+[^\s]+_NN[^\s]{0,2}/, # NOUN NOUN NOUN
        /[^\s]+_NN[^\s]{0,2}\s+[^\s]+_IN\s+[^\s]+_NN[^\s]{0,2}/ # NOUN PREP NOUN
      ]

      def self.analyze_pos(dataset)
        # PoS + FREQUENCY
        # Take only those that match the following patterns:
        # A N, N N, A A N, A N N, N A N, N N N, N P N
        # sort by frequency
        fail ArgumentError, 'NLP library not available' unless NLP_ENABLED

        # We actually aren't going to use compute_word_frequencies here; the
        # NLP POS tagger requires us to send it full sentences for maximum
        # accuracy.
        tagger = StanfordCoreNLP::MaxentTagger.new(POS_TAGGER_PATH)
        dataset.entries.inject({}) do |result, e|
          doc = Document.find(e.uid, fulltext: true)
          tagged = tagger.tagString(doc.fulltext).split

          (0..(tagged.size - 2)).map do |i|
            bigram = tagged[i, 2].join(' ')
            if POS_BI_REGEXES.any? { |r| bigram =~ r }
              stripped = bigram.gsub(/_(JJ[^\s]?|NN[^\s]{0,2}|IN)(\s+|\Z)/, '\2')

              result[stripped] ||= 0
              result[stripped] += 1
            end

            if i != tagged.size - 3
              trigram = tagged[i, 3].join(' ')
              if POS_TRI_REGEXES.any? { |r| trigram =~ r }
                stripped = trigram.gsub(/_(JJ[^\s]?|NN[^\s]{0,2}|IN)(\s+|\Z)/, '\2')

                result[stripped] ||= 0
                result[stripped] += 1
              end
            end
          end

          result
        end
      end
      # :nocov:
    end

  end
end
