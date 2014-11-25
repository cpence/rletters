
# -*- encoding : utf-8 -*-

module RLetters
  module Analysis
    module Frequency
      # Compute word frequency information directly
      #
      # If we have requested a 1-gram word frequency analysis for a single block,
      # then we can analyze the words simply by reading the +tf+ values from the
      # term vectors, which is much faster than reconstructing the full text from
      # the +offsets.+
      class FromTF < RLetters::Analysis::Frequency::Base
        # Run a TF-based analysis
        #
        # @param [Dataset] dataset The dataset to analyze
        # @param [Proc] progress If set, a function to call with a percentage
        #   of completion (one Integer parameter)
        # @param [Hash] options Parameters for how to compute word frequency
        # @option options [Integer] :num_words If set, only return frequency
        #   data for this many words; otherwise, return all words.
        # @option options [String] :inclusion_list If specified, then the
        #   analyzer will only compute frequency information for the words that
        #   are specified in this list (which is space-separated).
        # @option options [String] :exclusion_list If specified, then the
        #   analyzer will *not* compute frequency information for the words
        #   that are specified in this list (which is space-separated).
        # @option options [Documents::StopList] :stop_list If specified, then
        #   the analyzer will *not* compute frequency information for the words
        #   that appear within this stop list.
        # @option options [String] split_across whether to split blocks across
        #   documents
        #
        #   If this is set to true, then we will effectively concatenate all
        #   the documents before splitting into blocks.  If false, we'll
        #   split blocks on a per-document basis.  Defaults to true.
        def initialize(dataset, progress = nil, options = {})
          # Save the options
          normalize_options(options)
          @split_across = options[:split_across] || true
          @documents = RLetters::Datasets::DocumentEnumerator.new(
            dataset,
            term_vectors: true
          )

          # Compute the DF and TF values for the whole dataset and cull the
          # word list
          compute_df_tf(progress)

          @word_list = @tf_in_dataset.keys
          sorted_pairs = @tf_in_dataset.to_a.sort { |a, b| b[1] <=> a[1] }
          @word_list = sorted_pairs.map { |a| a[0] }
          cull_words

          # We're treating either the entire dataset or individual documents
          # as a single block
          @split_across ? single_block_analysis : doc_block_analysis(progress)
          progress.call(100) if progress
        end

        private

        # Analyze the entire dataset as a single block
        #
        # This function converts +@tf_in_dataset+ into a single block for the
        # entire dataset.
        #
        # @api private
        # @return [void]
        def single_block_analysis
          # Just copy everything out, rejecting any words not in the list to
          # be analyzed
          @blocks = [@tf_in_dataset.reject { |k, v| !@word_list.include?(k) }]
          @block_stats = [{
            name: I18n.t('lib.frequency.block_count_dataset',
                         num: 1, total: 1),
            types: @num_dataset_types,
            tokens: @num_dataset_tokens
          }]
        end

        # Analyze each document in the dataset as a separate block
        #
        # This function creates blocks for each of the documents in the
        # dataset, including only the words specified in +@word_list+.
        #
        # @api private
        # @param [Proc] progress If set, a function to call with a percentage
        #   of completion (one Integer parameter)
        # @return [void]
        def doc_block_analysis(progress)
          total = @documents.size.to_f

          @blocks = @documents.each_with_index.map do |d, i|
            progress.call((i.to_f / total * 40.0).to_i + 40) if progress

            d.term_vectors.each_with_object do |(k, v), ret|
              next unless @word_list.include?(k)
              ret[k] = v[:tf]
            end
          end

          progress.call(80) if progress

          # Clean out zero values from the blocks
          @blocks.map! do |b|
            b.reject! { |k, v| v.to_i == 0 }
          end

          progress.call(90) if progress

          @block_stats = @documents.each_with_index.map do |d, i|
            progress.call((i.to_f / total * 10.0).to_i + 90) if progress

            {
              name: I18n.t('lib.frequency.block_count_doc',
                           num: 1, total: 1, title: d.uid),
              types: d.term_vectors.size,
              tokens: d.term_vectors.map { |k, v| v[:tf] }.reduce(:+)
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
        # @api private
        # @param [Proc] progress If set, a function to call with a percentage
        #   of completion (one Integer parameter)
        # @return [void]
        def compute_df_tf(progress)
          @tf_in_dataset = {}
          @df_in_dataset = {}
          @df_in_corpus = {}

          total = @documents.size.to_f

          @documents.each_with_index do |d, i|
            d.term_vectors.each do |k, v|
              @tf_in_dataset[k] ||= 0
              @tf_in_dataset[k] += v[:tf]

              @df_in_dataset[k] ||= 0
              @df_in_dataset[k] += 1

              if !@df_in_corpus[k] && v[:df] > 0
                @df_in_corpus[k] = v[:df]
              end
            end

            # Call the progress function appropriately
            if progress
              p = i.to_f / total
              p *= @split_across ? 90.0 : 40.0
              progress.call(p.to_i)
            end
          end

          @num_dataset_types = @tf_in_dataset.size
          @num_dataset_tokens = @tf_in_dataset.values.reduce(:+)

          progress.call(@split_across ? 90 : 40) if progress
        end
      end
    end
  end
end
