
module RLetters
  module Analysis
    # Various analyzers for cooccurrence patterns
    #
    # Co-occurrences, as opposed to collocations, are words whose appearance is
    # statistically significantly correlated, but which (unlike collocations)
    # do *not* appear directly adjacent to one another.
    #
    # This analyzer takes a given word and returns all pairs in which that
    # word appears, sorted by significance.
    #
    # @!attribute dataset
    #   @return [Dataset] the dataset to analyze
    # @!attribute scoring
    #   @return [Symbol] the scoring method to use. Can be
    #     `:log_likelihood`, `:mutual_information`, or `:t_test`.
    # @!attribute num_pairs
    #   @return [Integer] the number of cooccurrences to return
    # @!attribute all
    #   @return [Boolean] if set to true, return all pairs
    # @!attribute words
    #   @return [String] one or more words to analyze. If this is a
    #     single word, the analyzer will return the top +num_pairs+ pairs
    #     containing that word. If it is a space-separated list of words, it
    #     will analyze all and only the combinations of those words.
    # @!attribute window
    #   @return [Integer] the window size to use for analysis.
    #     The default size of 200 approximates "paragraph-level" cooccurrence
    #     analysis.
    # @!attribute stemming
    #   @return [Symbol] the stemming method to use; can be +nil+ for
    #     no stemming, +:stem+ for basic Porter stemming, or +:lemma+ for
    #     full lemmatization
    # @!attribute progress
    #   @return [Proc] if set, a function to call with percentage of
    #     completion (one integer parameter)
    class Cooccurrence
      include Service
      include Virtus.model(strict: true, required: false, nullify_blank: true)

      attribute :dataset, Dataset, required: true
      attribute :words, VirtusExt::SplitList, required: true
      attribute :scoring, Symbol, required: true
      attribute :progress, Proc
      attribute :num_pairs, Integer, default: 0
      attribute :all, Boolean, default: false
      attribute :window, Integer, default: 200
      attribute :stemming, Symbol

      attribute :score_class, Class
      attribute :pairs, Hash

      # Perform cooccurrence analysis
      #
      # @return [RLetters::Analysis::Cooccurrence::Result] the analysis results
      def call
        case scoring
        when :log_likelihood
          score_class = Scoring::LogLikelihood
        when :mutual_information
          score_class = Scoring::MutualInformation
        when :t_test
          score_class = Scoring::TTest
        else
          fail ArgumentError, "#{scoring} is an invalid scoring method"
        end

        case stemming
        when :lemma
          self.words = NLP.lemmatize_words(words)
        when :stem
          words.map!(&:stem)
        end

        if words.size > 1
          # Don't go by count, take all the pairs
          self.num_pairs = nil

          self.pairs = {}
          combos = words.combination(2).to_a
          combos.group_by(&:first).each { |k, v| pairs[k] = v.map(&:last) }
        else
          # Just one word, use the most frequent num_pairs
          self.pairs = { words[0] => [] }
        end

        # Ignore num_pairs if we want all of the cooccurrences
        self.num_pairs = nil if all || num_pairs&.<=(0)

        base_frequencies, joint_frequencies, n = frequencies
        total_i = pairs.size.to_f

        n = n.to_f
        ret = []

        pairs.each_with_index do |(word, word_2_array), i|
          f_a = base_frequencies[word].to_f

          # Loop over the right array -- either just the words that we want
          # to query, or all of them
          if word_2_array.empty?
            enum = base_frequencies.each_key
          else
            enum = word_2_array.each
          end
          total_words = enum.size.to_f

          enum.each_with_index do |word_2, j|
            if progress
              p = (i.to_f / total_i) + (1 / total_i) * j.to_f / total_words
              progress.call((p * 33.0).to_i + 66)
            end
            next if word_2 == word

            f_b = base_frequencies[word_2].to_f
            f_ab = joint_frequencies[word][word_2].to_f

            ret << [word + ' ' + word_2,
                    score_class.score(f_a, f_b, f_ab, n)]
          end
        end

        ret.compact!
        ret = score_class.sort_results(ret).take(num_pairs) if num_pairs

        progress&.call(100)

        Result.new(cooccurrences: ret, scoring: scoring, stemming: stemming)
      end

      private

      # Return frequency counts
      #
      # All cooccurrence analyzers use the same input data -- the frequency
      # of words in bins of the given window size. This function computes
      # that data.
      #
      # Also, putting this in its own function *should* encourage the GC to
      # clean up the analyzer object after this function returns.
      #
      # @return [Array<(Hash<String, Integer>, Hash<String, Integer>, Integer)]
      #   First, the number of bins in which every word in the dataset
      #   appears (the +base_frequencies+). Second, the number of bins in
      #   which every word *and* the word at issue both appear (the
      #   +joint_frequencies+). Lastly, the number of bins (+n+).
      def frequencies
        analyzer = Frequency.call(
          dataset: dataset,
          stemming: stemming,
          block_size: window,
          last_block: :small_last,
          split_across: false,
          progress: lambda { |p| progress&.call((p.to_f / 100.0 * 33.0).to_i) })

        # Combine all the block hashes, summing the values
        total = analyzer.blocks.size.to_f

        base_frequencies = {}
        analyzer.blocks.each_with_index do |b, i|
          progress&.call((i.to_f / total * 16.0).to_i + 33)

          b.each_key do |k|
            base_frequencies[k] ||= 0
            base_frequencies[k] += 1
          end
        end

        # Get the frequencies of cooccurrence with the word in question
        joint_frequencies = {}
        pairs.each_with_index do |(word, word_2_array), i|
          joint_frequencies[word] = {}

          analyzer.blocks.each_with_index do |b, j|
            if progress
              p = ((i.to_f) / pairs.size.to_f) +
                  (1 / pairs.size.to_f) * (j.to_f / total.to_f)
              progress.call((p * 17.0).to_i + 49)
            end

            next unless b[word]&.>(0)

            if word_2_array.empty?
              b.each_key do |k|
                joint_frequencies[word][k] ||= 0
                joint_frequencies[word][k] += 1
              end
            else
              word_2_array.each do |w|
                if b.keys.include?(w)
                  joint_frequencies[word][w] ||= 0
                  joint_frequencies[word][w] += 1
                end
              end
            end
          end
        end

        [base_frequencies, joint_frequencies, analyzer.blocks.size]
      end
    end
  end
end
