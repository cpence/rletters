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

      def perform
        # Fetch the user based on ID
        user = User.find(user_id)
        raise ArgumentError, 'User ID is not valid' unless user
      
        # Fetch the dataset based on ID
        dataset = user.datasets.find(dataset_id)
        raise ArgumentError, 'Dataset ID is not valid' unless dataset

        # Make a new analysis task
        @task = dataset.analysis_tasks.create(:name => "Word frequency list", :job_type => 'WordFrequency')

        # Normalize the parameters
        @num_blocks = 0 if @num_blocks.nil?
        @block_size = 0 if @block_size.nil?
        @num_words = 0 if @num_words.nil?
        @split_across = true if @split_across.nil?
        
        if @num_blocks > 0 && @block_size > 0
          # If we get num_blocks *and* block_size, something's amiss; just
          # take block_size
          @num_blocks = 0
        end
        if @num_blocks <= 0 && @block_size <= 0
          @num_blocks = 1
        end
        if @num_words < 0
          @num_words = 0
        end

        by_count = (@num_blocks > 0)

        # Things we'll eventually fill in
        num_dataset_types = 0
        num_dataset_tokens = 0
        num_remainder_blocks = 0

        flat_word_counts = []
        
        # Count types and tokens in the whole dataset; we need this to compute
        # block sizes if you have num_blocks and split_across selected, so do it
        # early.  Also, compute the parallel list counts here, which we can do
        # quicker (without creating the ordered list).
        dataset.entries.each do |e|
          doc = Document.find_with_fulltext e.shasum
          tv = doc.term_vectors

          tv.each do |word, hash|
            next if hash[:tf] == 0
            
            flat_word_counts << [word, 0] unless flat_word_counts.assoc(word)
            flat_word_counts.assoc(word)[1] += hash[:tf]
            num_dataset_tokens += hash[:tf]
          end
        end

        # This is the number of types in the dataset
        num_dataset_types = flat_word_counts.count

        # Sort the flat word counts
        flat_word_counts.sort do |a, b|
          b[1] <=> a[1]
        end

        # Take the first num_words words for the list (FIXME: here's where we
        # would do *least* frequent if we wanted)
        if @num_words != 0
          words_to_take = flat_word_counts.take(@num_words).map { |a| a[0] }
        else
          words_to_take = flat_word_counts.map { |a| a[0] }
        end

        # If we're split_across, we can now compute block_size from num_blocks
        # and vice versa
        if @split_across
          if by_count
            @block_size = (num_dataset_tokens / @num_blocks.to_f).floor
            num_remainder_blocks = num_dataset_tokens - (@block_size * @num_blocks)
            block_name_base = "Block %{num}/#{num_blocks} (across dataset)"
          else
            @num_blocks = (num_dataset_tokens / @block_size.to_f).ceil
            block_name_base = "Block %{num} of #{block_size} words (across dataset)"
          end
        else
          if by_count
            block_name_base = "Block %{num}/#{num_blocks} (within %{doc})"
          else
            block_name_base = "Block %{num} of #{block_size} words (within %{doc})"
          end
        end

        block_number = 0
        block_counter = 0
        block_types = 0
        block_tokens = 0

        # Set up an empty block
        block = {}
        words_to_take.each do |w|
          block[w] = 0
        end
        
        blocks = []
        block_stats = []
        
        # Process all of the documents
        dataset.entries.each do |e|
          doc = Document.find_with_fulltext e.shasum
          tv = doc.term_vectors

          # If we're not splitting across, then we need to see how big the
          # blocks are / how many blocks we have for this document
          unless split_across
            block_number = 0
            block_counter = 0
            doc_tokens = 0
            tv.each do |word, hash|
              doc_tokens += hash[:tf]
            end

            num_remainder_blocks = 0
            if by_count
              @block_size = (doc_tokens / @num_blocks.to_f).floor
              num_remainder_blocks = doc_tokens - (@num_blocks * @block_size)
            else
              @num_blocks = (doc_tokens / @block_size.to_f).ceil
            end
          end
          
          # Create a single array that has the words in the document sorted
          # by position
          sorted_words = []
          tv.each do |word, hash|
            next if hash[:tf] == 0
            
            hash[:positions].each do |p|
              sorted_words << [ word, p ]
            end
          end
          sorted_words.sort! { |a, b| a[1] <=> b[1] }
          sorted_words.map! { |x| x[0] }

          # Do the processing for this document
          sorted_words.each do |word|
            next unless words_to_take.include? word

            block[word] += 1
            block_tokens += 1
            
            if block[word] == 1
              block_types += 1
            end

            block_counter = block_counter + 1

            # If the block size doesn't divide evenly into the number of blocks
            # that we want, we want to consume the remainder one at a time over
            # the course of all the blocks, and *not* leave it until the end, or
            # else we wind up with one block that contains all the remainder,
            # despite the fact that we were trying to divide evenly.
            check_size = @block_size
            if num_remainder_blocks != 0
              check_size = @block_size + 1
            end
            
            if block_counter >= check_size
              num_remainder_blocks -= 1 if num_remainder_blocks != 0
              block_number += 1
              
              block_name = block_name_base % { :num => block_number, :doc => "\"#{doc.title}\"" }
              block_stats << { :name => block_name, :types => block_types, :tokens => block_tokens }
              blocks << block.dup

              words_to_take.each do |w|
                block[w] = 0
              end

              block_counter = 0
              block_types = 0
              block_tokens = 0
            end
          end

          # If we're not splitting across, we need to force the end of this
          # block if there's anything in it.
          if !split_across && block_counter != 0
            block_number += 1
            block_name = block_name_base % { :num => block_number, :doc => "\"#{doc.title}\"" }
            block_stats << { :name => block_name, :types => block_types, :tokens => block_tokens }
            blocks << block.dup

            words_to_take.each do |w|
              block[w] = 0
            end

            block_counter = 0
            block_types = 0
            block_tokens = 0
          end
        end

        # If we are splitting across, we need to put the last block into the
        # list
        if split_across && block_counter != 0
          block_number += 1
          block_name = block_name_base % { :num => block_number, :doc => '' }
          block_stats << { :name => block_name, :types => block_types, :tokens => block_tokens }
          blocks << block.dup
        end

        # Create some YAML
        output = {}
        output[:blocks] = blocks
        output[:block_stats] = block_stats
        output[:dataset_stats] = { :types => num_dataset_types, :tokens => num_dataset_tokens }

        @task.result_file = Download.create_file('frequency.yml') do |file|
          file.write(output.to_yaml)
          file.close
        end
        
        # Make sure the task is saved, setting 'finished_at'
        @task.finished_at = DateTime.current
        @task.save
      end
      
      # We don't want users to download the YAML file
      def self.download?; false; end
    end
  end
end

