# frozen_string_literal: true

module RLetters
  module Documents
    # Splits a group of documents into configurable blocks
    #
    # @!attribute word_lister
    #   @return [RLetters::Documents::WordList] The word lister used to create
    #     these segments (can be passed in or created automatically)
    # @!attribute num_blocks
    #   @return [Integer] If set, split the text into this number of blocks
    #     (defaults to 1)
    # @!attribute block_size
    #   @return [Integer] If set, split the text into blocks of this size
    #    (defaults to unset, using +:num_blocks+ instead)
    # @!attribute last_block
    #   @return [Symbol] This parameter changes what will happen to the
    #     "leftover" words when +block_size+ is set.
    #
    #     [+:big_last+]      add them to the last block, making a block larger
    #       than +block_size+.
    #     [+:small_last+]    make them into their own block, making a block
    #       smaller than +block_size+.
    #     [+:truncate_last+] truncate those leftover words, excluding them from
    #       frequency computation.
    #     [+:truncate_all+]  truncate _every_ text to +block_size+, creating only
    #       one block per call to +#add+
    #
    #     The default is +:big_last+.
    # @!attribute [r] words_for_last
    #   Return the words in the last document
    #
    #   For generating document frequencies, this returns a uniquified list of
    #   the words found in the last document scanned
    #
    #   @return [Array<String>] words in the document last scanned by +add+
    # @!attribute corpus_dfs
    #   @return [Hash<String, Integer>] A hash where the keys are the words in
    #     the document and the values are the document frequencies in the
    #     entire corpus (the number of documents in the corpus in which the
    #     word appears).
    #   @note This will only return values for words appearing in the
    #     documents that have been scanned by +add+
    class Segments
      include Virtus.model(strict: true, required: false, nullify_blank: true)
      include VirtusExt::ParameterHash
      include VirtusExt::Validator

      attribute(:word_lister, WordList,
                default: lambda do |segmenter, _|
                  WordList.new(segmenter.parameter_hash)
                end)
      attribute :num_blocks, Integer, default: 1
      attribute :block_size, Integer, default: 0
      attribute :last_block, Symbol, default: :big_last

      attribute :words_for_last, Array[String], writer: :private
      attribute :corpus_dfs, Hash[String => Integer], writer: :private

      attribute :block_list, Array, reader: :private, writer: :private
      attribute :single_block, Array, reader: :private, writer: :private

      # Reset this segmenter
      #
      # Delete all blocks and clear to original configuration
      #
      # @return [void]
      def reset!
        self.words_for_last = []
        self.corpus_dfs = {}
        self.block_list = []
        self.single_block = []
      end

      # Add a document to this segmenter
      #
      # We add documents one-at-a-time to the segmenter, rather than by reading
      # all of them in at once.  This keeps us from using twice the memory that
      # we otherwise would by reading in and *then* splitting.
      #
      # @param [String] uid the UID of the document to add to the segmenter
      # @return [void]
      def add(uid)
        words = word_lister.words_for(uid)

        self.words_for_last = words.uniq
        corpus_dfs.merge!(word_lister.corpus_dfs)

        num_blocks > 0 ? add_for_num_blocks(words) : add_for_block_size(words)
      end

      # Return the blocks from this segmenter
      #
      # This function finalizes the segmenter's blocks and returns them.  If we
      # are splitting by the *number* of blocks, that splitting is done here, as
      # we don't know how big the blocks will be until we're finished.
      #
      # @return [Array<Block>] a list of blocks of words for these documents
      def blocks
        if num_blocks > 0
          blocks_for_num_blocks
        else
          blocks_for_block_size
        end
      end

      private

      # Validate parameter values after the constructor finishes
      #
      # @return [void]
      def validate!
        # If we get num_blocks and block_size, then the user's done something
        # wrong; just take block_size
        self.num_blocks = 0 if num_blocks > 0 && block_size > 0

        # Default to a single block unless otherwise specified
        self.num_blocks = 1 if num_blocks <= 0 && block_size <= 0

        reset!
      end

      # Add a list of words to the blocks (for a given number of blocks)
      #
      # @param [Array<String>] words the word list to add to the blocks
      # @return [void]
      def add_for_num_blocks(words)
        # We just add to the single block, and we split this when we call
        # #blocks
        single_block.concat(words)
      end

      # Add a list of words to the blocks (for a given block size)
      #
      # @param [Array<String>] words the word list to add to the blocks
      # @return [void]
      def add_for_block_size(words)
        # If we're running :truncate_all, then just append the block for this
        # document and return
        if last_block == :truncate_all
          if block_list.empty?
            name = I18n.t('lib.frequency.block_size_dataset',
                          num: block_list.size + 1, size: block_size)
            block_list.push(Block.new(words: words[0...block_size],
                                      name: name))
          end
          return
        end

        # Make the first block, if needed
        unless block_list.last
          block_list.push(
            Block.new(
              words: [],
              name: I18n.t('lib.frequency.block_size_dataset',
                           num: 1, size: block_size)
            )
          )
        end

        # Fill up the last block
        current_left = block_size - block_list.last.words.size
        if current_left > 0
          block_list.last.words.concat(words.shift(current_left))
        end

        # Bail if there weren't enough words in the document to finish that block
        return if block_list.last.words.size < block_size

        # Turn the remaining words into blocks and append
        words.in_groups_of(block_size, false).each do |b|
          name = I18n.t('lib.frequency.block_size_dataset',
                        num: block_list.size + 1, size: block_size)
          block_list.push(Block.new(words: b, name: name))
        end
      end

      # Get the list of blocks (for a given number of blocks)
      #
      # @return [Array<Array<String>>] the blocks for this segmenter
      def blocks_for_num_blocks
        # Don't create blocks if we have no words
        return [] if single_block.empty?

        # Split the single block into the right size and return
        single_block.in_groups(num_blocks, false).each_with_object([]) do |b, ret|
          ret << Block.new(words: b,
                           name: I18n.t('lib.frequency.block_count_dataset',
                                        num: ret.size + 1, total: num_blocks))
        end
      end

      # Get the list of blocks (for a given block size)
      #
      # @return [Array<Array<String>>] the blocks for this segmenter
      def blocks_for_block_size
        # We're already done with the last block behavior, if we wanted a small
        # last block, or if we only generated a single block
        return block_list if block_list.size <= 1 || last_block == :small_last

        case last_block
        when :truncate_all
          # Implemented in add_for_block_size
        when :small_last
          # Implemented just above
        when :truncate_last
          block_list.pop
        else # default to :big_last behavior
          last = block_list.pop
          block_list.last.words.concat(last.words)
        end

        block_list
      end
    end
  end
end
