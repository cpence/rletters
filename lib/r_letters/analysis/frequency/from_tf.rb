# frozen_string_literal: true

module RLetters
  module Analysis
    module Frequency
      # Compute word frequency information directly
      #
      # If we have requested a 1-gram word frequency analysis for a single
      # block, then we can analyze the words simply by reading the +tf+ values
      # from the term vectors, which is much faster than reconstructing the
      # full text from the +offsets.+
      class FromTF < RLetters::Analysis::Frequency::Base
        # N.B.: Do not coerce this value, as it is an enumerator, and Virtus
        # will try to coerce it as an array of objects.
        attribute(:documents, Datasets::DocumentEnumerator,
                  reader: :private, writer: :private, coerce: false,
                  default: lambda do |analyzer, _|
                    Datasets::DocumentEnumerator.new(dataset: analyzer.dataset,
                                                     term_vectors: true)
                  end)

        # Run a TF-based analysis
        #
        # @return [self]
        def call
          # Compute the DF and TF values for the whole dataset and cull the
          # word list
          compute_df_tf

          self.word_list = tf_in_dataset.keys
          sorted_pairs = tf_in_dataset.to_a.sort { |a, b| b[1] <=> a[1] }
          self.word_list = sorted_pairs.map { |a| a[0] }
          cull_words

          # We're treating either the entire dataset or individual documents
          # as a single block
          split_across ? single_block_analysis : doc_block_analysis
          progress&.call(100)

          self
        end

        private

        # Analyze the entire dataset as a single block
        #
        # This function converts +tf_in_dataset+ into a single block for the
        # entire dataset.
        #
        # @return [void]
        def single_block_analysis
          # Just copy everything out, rejecting any words not in the list to
          # be analyzed
          self.blocks = [
            tf_in_dataset.select { |k, _| word_list.include?(k) }
          ]
          self.block_stats = [{
            name: I18n.t('lib.frequency.block_count_dataset',
                         num: 1, total: 1),
            types: num_dataset_types,
            tokens: num_dataset_tokens
          }]
        end

        # Analyze each document in the dataset as a separate block
        #
        # This function creates blocks for each of the documents in the
        # dataset, including only the words specified in +word_list+.
        #
        # @return [void]
        def doc_block_analysis
          total = documents.size.to_f

          self.blocks = documents.each_with_index.map do |d, i|
            progress.call((i.to_f / total * 40.0).to_i + 40) if progress

            d.term_vectors.each_with_object({}) do |(k, v), ret|
              next unless word_list.include?(k)
              ret[k] = v[:tf]
            end
          end

          progress&.call(80)

          # Clean out zero values from the blocks
          blocks.map! do |b|
            b.reject { |_, v| v.to_i.zero? }
          end

          progress&.call(90)

          self.block_stats = documents.each_with_index.map do |d, i|
            progress&.call((i.to_f / total.to_f * 10).to_i + 90)

            {
              name: I18n.t('lib.frequency.block_count_doc',
                           num: 1, total: 1, title: d.uid),
              types: d.term_vectors.size,
              tokens: d.term_vectors.map { |_, v| v[:tf] }.reduce(:+)
            }
          end
        end

        # Compute the df and tf for all the words in the dataset
        #
        # This function computes and sets +df_in_dataset+ and +tf_in_dataset+,
        # for all the words in the dataset.  Note that this
        # function ignores the +num_words+ parameter, as we need these tf
        # values to sort in order to obtain the most/least frequent words.
        #
        # All three of these variables are hashes, with the words as String
        # keys and the tf/df values as Integer values.
        #
        # Finally, this function also sets +num_dataset_types+ and
        # +num_dataset_tokens+, as we can compute them easily here.
        #
        # Note that there is no such thing as +tf_in_corpus+, as this would be
        # incredibly, prohibitively expensive and is not provided by Solr.
        #
        # @return [void]
        def compute_df_tf
          self.tf_in_dataset = {}
          self.df_in_dataset = {}
          self.df_in_corpus = {}

          total = documents.size.to_f

          documents.each_with_index do |d, i|
            d.term_vectors.each do |k, v|
              tf_in_dataset[k] ||= 0
              tf_in_dataset[k] += v[:tf]

              df_in_dataset[k] ||= 0
              df_in_dataset[k] += 1

              df_in_corpus[k] = v[:df] if !df_in_corpus[k] && v[:df].positive?
            end

            # Call the progress function appropriately
            next unless progress
            p = i.to_f / total
            p *= split_across ? 90.0 : 40.0
            progress.call(p.to_i)
          end

          self.num_dataset_types = tf_in_dataset.size
          self.num_dataset_tokens = tf_in_dataset.values.reduce(:+)

          progress&.call(split_across ? 90 : 40)
        end
      end
    end
  end
end
