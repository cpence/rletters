# -*- encoding : utf-8 -*-
require 'csv'

module Jobs
  module Analysis
    # Determine statistically significant collocations in text
    class Collocation < Jobs::Analysis::Base
      include Resque::Plugins::Status

      # Set the queue for this task
      def self.queue
        :analysis
      end

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
      # @param [Hash] options parameters for this job
      # @option options [String] user_id the user whose dataset we are to work on
      # @option options [String] dataset_id the dataset to operate on
      # @option options [String] task_id the analysis task we're working from
      # @option options [String] analysis_type the algorithm to use to analyze the
      #   significance of collocations.  Can be 'mi' (for mutual
      #   information), 't' (for t-test), 'likelihood' (for log-likelihood),
      #   or 'pos' (for part-of-speech biased frequencies).
      # @option options [String] num_pairs number of collocations to return
      # @option options [String] word if present, return only collocations
      #   including this word
      # @return [undefined]
      # @example Start a job for locating collocations
      #   Jobs::Analysis::Collocation.create(user_id: current_user.to_param,
      #                                      dataset_id: dataset.to_param,
      #                                      task_id: task.to_param,
      #                                      analysis_type: 't',
      #                                      num_pairs: '50')
      def perform
        options.clean_options!
        at(0, 100, 'Initializing...')

        user = User.find(options[:user_id])
        @dataset = user.datasets.active.find(options[:dataset_id])
        task = @dataset.analysis_tasks.find(options[:task_id])

        task.name = t('.short_desc')
        task.save

        analysis_type = (options[:analysis_type] || :mi).to_sym
        num_pairs = (options[:num_pairs] || 50).to_i
        @word = options[:word].mb_chars.downcase.to_s if options[:word]

        # Part of speech tagging requires the Stanford NLP
        analysis_type = :mi if !NLP_ENABLED && analysis_type == :pos

        case analysis_type
        when :mi
          algorithm = t('.mi')
          column = t('.mi_column')
          grams = analyze_mutual_information
        when :t
          algorithm = t('.t')
          column = t('.t_column')
          grams = analyze_t_test
        when :likelihood
          algorithm = t('.likelihood')
          column = t('.likelihood_column')
          grams = analyze_likelihood
        when :pos
          # :nocov:
          algorithm = t('.pos')
          column = t('.pos_column')
          grams = analyze_pos
          # :nocov:
        else
          fail ArgumentError, 'Invalid value for analysis_type'
        end

        # Save out all the data
        at(100, 100, 'Finished, generating output...')
        csv_string = CSV.generate do |csv|
          csv << [t('.header', name: @dataset.name)]
          csv << [t('.subheader', test: algorithm)]
          csv << ['']

          csv << [t('.pair'), column]
          grams.take(num_pairs).each do |w, v|
            csv << [w, v]
          end

          csv << ['']
        end

        # Write it out
        ios = StringIO.new(csv_string)
        file = Paperclip.io_adapters.for(ios)
        file.original_filename = 'collocation.csv'
        file.content_type = 'text/csv'

        task.result = file

        # We're done here
        task.finish!

        completed
      end

      # We don't want users to download the JSON file
      def self.download?
        true
      end

      # Helper method for creating the job parameters view
      #
      # This method returns the list of available significance test methods.
      def self.significance_tests
        [:mi, :t, :likelihood, :pos].map do |sym|
          [t(".#{sym}"), sym]
        end
      end

      private

      # Return two analyzers for doing collocation analysis
      #
      # Many of the analysis methods here need two analyzers -- one that will
      # analyze one-grams, and one that will analyze bigrams, so that we can
      # use frequency information from each for comparison.  This function
      # builds those two analyzers.
      #
      # @api private
      # @return [Array<RLetters::Analysis::Frequency::FromTF>] two analyzers,
      #   first one-gram and second bi-gram
      def analyzers_for_collocation
        # The onegram analyzer can use TFs
        onegram_analyzer = RLetters::Analysis::Frequency::FromTF.new(
          @dataset,
          ->(p) { at((p.to_f / 100.0 * 33.0).to_i + 33, 100,
                     'Computing frequencies for one-grams...') })

        # The bigrams should only include the focal word, if the user has
        # restricted the analysis
        bigram_opts = {}
        bigram_opts[:inclusion_list] = @word if @word

        wl = RLetters::Documents::WordList.new(ngrams: 2)
        ds = RLetters::Documents::Segments.new(wl, num_blocks: 1)
        ss = RLetters::Datasets::Segments.new(@dataset, ds, split_across: true)
        bigram_analyzer = RLetters::Analysis::Frequency::FromPosition.new(
          ss,
          ->(p) { at((p.to_f / 100.0 * 33.0).to_i + 66, 100,
                     'Computing frequencies for bi-grams...') },
          bigram_opts)

        [onegram_analyzer, bigram_analyzer]
      end

      def analyze_mutual_information
        # MUTUAL INFORMATION
        # PMI(a, b) = log [ (f(a b) / N) / (f(a) f(b) / N^2) ]
        # with N the number of single-word tokens
        analyzers = analyzers_for_collocation

        word_f = analyzers[0].blocks[0]
        bigram_f = analyzers[1].blocks[0]
        total = bigram_f.size

        n = analyzers[0].num_dataset_tokens.to_f
        n_2 = n * n

        bigram_f.each_with_index.map { |b, i|
          at((i.to_f / total.to_f * 33.0).to_i + 66, 100, 'Computing mutual information for collocations...')

          bigram_words = b[0].split
          l = (b[1].to_f / n) /
              (word_f[bigram_words[0]].to_f * word_f[bigram_words[1]].to_f / n_2)
          l = Math.log(l) unless l.abs < 0.001

          [b[0], l]
        }.sort { |a, b| b[1] <=> a[1] }
      end

      def analyze_t_test
        # T-TEST
        # Pr(a) = f(a) / N
        # Pr(b) = f(b) / N
        # H0 = independent occurrences A and B = Pr(a) * Pr(b)
        # x = f(a b) / N
        # s^2 = H0 * (1 - H0)
        # t = (x - H0) / sqrt(s^2 / N)
        # convert t to a p-value based on N
        #   1 - Distribution::T.cdf(t, N-1)
        analyzers = analyzers_for_collocation

        word_f = analyzers[0].blocks[0]
        bigram_f = analyzers[1].blocks[0]
        total = bigram_f.size

        n = analyzers[0].num_dataset_tokens.to_f

        bigram_f.each_with_index.map { |b, i|
          at((i.to_f / total.to_f * 33.0).to_i + 66, 100, 'Computing t-tests for collocations...')

          bigram_words = b[0].split
          h_0 = (word_f[bigram_words[0]].to_f / n) *
                (word_f[bigram_words[1]].to_f / n)
          t = ((b[1].to_f / n) - h_0) / Math.sqrt((h_0 * (1.0 - h_0)) / n)
          p = 1.0 - Distribution::T.cdf(t, n - 1)

          [b[0], p]
        }.sort { |a, b| a[1] <=> b[1] }
      end

      def log_l(k, n, x)
        # L(k, n, x) = x^k (1 - x)^(n - k)
        l = x**k * ((1 - x)**(n - k))
        l = Math.log(l) unless l.abs < 0.001
        l
      end

      def analyze_likelihood
        # LIKELIHOOD RATIO
        # Log-lambda = log L(f(a b), f(a), f(a) / N) +
        #              log L(f(b) - f(a b), N - f(a), f(a) / N) -
        #              log L(f(a b), f(a), f(a b) / f(a)) -
        #              log L(f(b) - f(a b), N - f(a), (f(b) - f(a b)) / (N - f(a)))
        # sort by -2 log-lambda
        analyzers = analyzers_for_collocation

        word_f = analyzers[0].blocks[0]
        bigram_f = analyzers[1].blocks[0]
        total = bigram_f.size

        n = analyzers[0].num_dataset_tokens.to_f

        bigram_f.each_with_index.map { |b, i|
          at((i.to_f / total.to_f * 33.0).to_i + 66, 100, 'Computing likelihood ratios for collocations...')

          bigram_words = b[0].split
          f_ab = b[1].to_f
          f_a = word_f[bigram_words[0]].to_f
          f_b = word_f[bigram_words[1]].to_f

          ll = log_l(f_ab, f_a, f_a / n) +
               log_l(f_b - f_ab, n - f_a, f_a / n) -
               log_l(f_ab, f_a, f_ab / f_a) -
               log_l(f_b - f_ab, n - f_a, (f_b - f_ab) / (n - f_a))
          [b[0], -2.0 * ll]
        }.sort { |a, b| b[1] <=> a[1] }
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

      def analyze_pos
        # PoS + FREQUENCY
        # Take only those that match the following patterns:
        # A N, N N, A A N, A N N, N A N, N N N, N P N
        # sort by frequency
        fail ArgumentError, 'NLP library not available' unless NLP_ENABLED
        total = @dataset.entries.size

        # We actually aren't going to use Analysis::WordFrequency here; the
        # NLP POS tagger requires us to send it full sentences for maximum
        # accuracy.
        tagger = StanfordCoreNLP::MaxentTagger.new(POS_TAGGER_PATH)
        enum = RLetters::Datasets::DocumentEnumerator.new(@dataset,
                                                          fulltext: true)
        enum.each_with_index.each_with_object({}) { |(doc, i), result|
          at((i.to_f / total.to_f * 100.0).to_i, 100, 'Computing parts of speech for documents...')

          tagged = tagger.tagString(doc.fulltext).split

          tagged.each_cons(2).map do |t|
            if @word
              next unless t.any? { |w| w.start_with?("#{@word}_") }
            end

            bigram = t.join(' ')
            if POS_BI_REGEXES.any? { |r| bigram =~ r }
              stripped = bigram.gsub(/_(JJ[^\s]?|NN[^\s]{0,2}|IN)(\s+|\Z)/, '\2')

              result[stripped] ||= 0
              result[stripped] += 1
            end
          end

          tagged.each_cons(3).map do |t|
            if @word
              next unless t.any? { |w| w.start_with?("#{@word}_") }
            end

            trigram = t.join(' ')
            if POS_TRI_REGEXES.any? { |r| trigram =~ r }
              stripped = trigram.gsub(/_(JJ[^\s]?|NN[^\s]{0,2}|IN)(\s+|\Z)/, '\2')

              result[stripped] ||= 0
              result[stripped] += 1
            end
          end
        }.sort { |a, b| b[1] <=> a[1] }
      end
      # :nocov:
    end
  end
end
