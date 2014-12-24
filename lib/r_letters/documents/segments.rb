
module RLetters
  module Documents
    # A text block resulting from dataset segmentation
    class Block
      # @return [Array<String>] The list of words in this block
      attr_accessor :words

      # @return [String] A user-friendly name for this block
      attr_accessor :name

      # Create a new block
      #
      # @api public
      # @param [Array<String>] words The list of words in this block
      # @param [String] name A user-friendly name for this block
      # @return [Block] A new block object
      def initialize(words, name)
        self.words = words
        self.name = name
      end
    end

    # Splits a group of documents into configurable blocks
    #
    # @!attribute [r] words_for_last
    #   Return the words in the last document
    #
    #   For generating document frequencies, this returns a uniquified list of
    #   the words found in the last document scanned
    #
    #   @return [Array<String>] words in the document last scanned by +add+
    # @!attribute [r] word_list
    #   @return [RLetters::Documents::WordList] the word lister used to create
    #     these segments
    class Segments
      # The valid values for the :last_block option
      VALID_LAST_BLOCK = [:big_last, :small_last, :truncate_last, :truncate_all]

      attr_reader :words_for_last, :word_list

      # Split some number of documents into text segments
      #
      # @api public
      # @param word_list [RLetters::Documents::WordList] a word list generator
      #   to use (if +nil+, create default)
      # @param [Hash] options options for the text segmentation
      # @option options [Integer] :num_blocks if set, split the text into this
      #   number of blocks (defaults to 1)
      # @option options [Integer] :block_size if set, split the text into blocks
      #   of this size (defaults to unset, using +:num_blocks+ instead)
      # @option options [Symbol] :last_block This parameter changes what will
      #   happen to the "leftover" words when +block_size+ is set.
      #
      #   [+:big_last+]      add them to the last block, making a block larger
      #     than +block_size+.
      #   [+:small_last+]    make them into their own block, making a block
      #     smaller than +block_size+.
      #   [+:truncate_last+] truncate those leftover words, excluding them from
      #     frequency computation.
      #   [+:truncate_all+]  truncate _every_ text to +block_size+, creating only
      #     one block per call to +#add+
      #
      #   The default is +:big_last+.
      def initialize(word_list = nil, options = {})
        @word_list = word_list || WordList.new
        @word_list.reset!
        @num_blocks = options[:num_blocks] || 0
        @block_size = options[:block_size] || 0
        @last_block = options[:last_block] || :big_last

        # If we get num_blocks and block_size, then the user's done something
        # wrong; just take block_size
        @num_blocks = 0 if @num_blocks > 0 && @block_size > 0

        # Default to a single block unless otherwise specified
        @num_blocks = 1 if @num_blocks <= 0 && @block_size <= 0

        # Make sure last_block is a legitimate value
        @last_block = :big_last unless VALID_LAST_BLOCK.include? @last_block

        reset!
      end

      # Reset this segmenter
      #
      # Delete all blocks and clear to original configuration
      #
      # @api public
      # @return [void]
      def reset!
        @words_for_last = []
        @blocks = []
        @single_block = []
      end

      # Add a document to this segmenter
      #
      # We add documents one-at-a-time to the segmenter, rather than by reading
      # all of them in at once.  This keeps us from using twice the memory that
      # we otherwise would by reading in and *then* splitting.
      #
      # @api public
      # @param [String] uid the UID of the document to add to the segmenter
      # @return [void]
      def add(uid)
        words = @word_list.words_for(uid)
        @words_for_last = words.uniq
        @num_blocks > 0 ? add_for_num_blocks(words) : add_for_block_size(words)
      end

      # Return the blocks from this segmenter
      #
      # This function finalizes the segmenter's blocks and returns them.  If we
      # are splitting by the *number* of blocks, that splitting is done here, as
      # we don't know how big the blocks will be until we're finished.
      #
      # @api public
      # @return [Array<Block>] a list of blocks of words for these documents
      def blocks
        @num_blocks > 0 ? blocks_for_num_blocks :
                          blocks_for_block_size
      end

      private

      # Add a list of words to the blocks (for a given number of blocks)
      #
      # @api private
      # @param [Array<String>] words the word list to add to the blocks
      # @return [void]
      def add_for_num_blocks(words)
        # We just add to the single block, and we split this when we call
        # #blocks
        @single_block += words
      end

      # Add a list of words to the blocks (for a given block size)
      #
      # @api private
      # @param [Array<String>] words the word list to add to the blocks
      # @return [void]
      def add_for_block_size(words)
        # If we're running :truncate_all, then just append the block for this
        # document and return
        if @last_block == :truncate_all
          if @blocks.empty?
            name = I18n.t('lib.frequency.block_size_dataset',
                          num: @blocks.size + 1, size: @block_size)
            @blocks << Block.new(words[0...@block_size], name)
          end
          return
        end

        # Make the first block, if needed
        unless @blocks.last
          @blocks << Block.new([], I18n.t('lib.frequency.block_size_dataset',
                                          num: 1, size: @block_size))
        end

        # Fill up the last block
        current_left = @block_size - @blocks.last.words.size
        @blocks.last.words += words.shift(current_left) if current_left > 0

        # Bail if there weren't enough words in the document to finish that block
        return if @blocks.last.words.size < @block_size

        # Turn the remaining words into blocks and append
        words.in_groups_of(@block_size, false).each do |b|
          name = I18n.t('lib.frequency.block_size_dataset',
                        num: @blocks.size + 1, size: @block_size)
          @blocks << Block.new(b, name)
        end
      end

      # Get the list of blocks (for a given number of blocks)
      #
      # @api private
      # @return [Array<Array<String>>] the blocks for this segmenter
      def blocks_for_num_blocks
        # Don't create blocks if we have no words
        return [] if @single_block.empty?

        # Split the single block into the right size and return
        @single_block.in_groups(@num_blocks, false).each_with_object([]) do |b, ret|
          ret << Block.new(b, I18n.t('lib.frequency.block_count_dataset',
                                     num: ret.size + 1, total: @num_blocks))
        end
      end

      # Get the list of blocks (for a given block size)
      #
      # @api private
      # @return [Array<Array<String>>] the blocks for this segmenter
      def blocks_for_block_size
        # We're already done with the last block behavior, if we wanted a small
        # last block, or if we only generated a single block
        return @blocks if @blocks.size <= 1 || @last_block == :small_last

        # Implement the last block behavior.  The :truncate_all behavior is
        # implemented in add_for_block_size.
        case @last_block
        when :big_last
          last = @blocks.pop
          @blocks.last.words += last.words
        when :truncate_last
          @blocks.pop
        end

        @blocks
      end
    end
  end
end
