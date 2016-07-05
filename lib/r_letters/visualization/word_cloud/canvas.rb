
module RLetters
  module Visualization
    # Code used only by word cloud generation
    class WordCloud
      # A class that handles word placement in the word cloud
      #
      # Thanks to Jake Gordon's sprite-factory gem for the rectangle-packing
      # code:
      # https://github.com/jakesgordon/sprite-factory/blob/master/lib/sprite_factory/layout/packed.rb
      #
      # @!attribute [r] width
      #   @return [Numeric] the width of the canvas required
      # @!attribute [r] height
      #   @return [Numeric] the height of the canvas required
      class Canvas
        attr_reader :width, :height

        # Create a new canvas object
        #
        # @param [Hash<String, Integer>] words a hash mapping a word to its
        #   point size
        # @param [String] font_path the path to the font to use
        def initialize(words:, font_path:)
          @font_path = font_path

          # Get the size of the bounding box for each word
          @extents = words.each_with_object({}) do |(word, size), ret|
            ret[word] = get_word_extents(word: word, size: size)
          end

          # Render each word to a PNG that we'll use to check whether words
          # overlap
          @clip_pngs = words.each_with_object({}) do |(word, size), ret|
            e = @extents[word]

            clip_image = create_new_image(width: e[:width].ceil + 10,
                                          height: e[:height].ceil + 10)
            clip_image.combine_options do |b|
              b.font(@font_path).pointsize(size)
              b.stroke('black').strokewidth(1).gravity('NorthWest')

              b.draw("text 5,5 \"#{word}\"")
            end

            ret[word] = ChunkyPNG::Image.from_file(clip_image.path)
          end

          # Take a guess at how much area we'll need to build the image
          calculate_canvas_size

          # Build the image where we'll store the clipping data
          @image = create_new_image(width: @width, height: @height)
        end

        # Place a word on the canvas, not overlapping with any others
        #
        # @param [String] word the word to place
        # @param [Integer] size the point size for the word
        # @return [void]
        def place_word(word:, size:)
          e = @extents[word]

          # Start at a random position on the center line
          x_0 = ((@width - e[:width]) / 2.0).round
          y_0 = Random.rand(@height).round

          # It's possible that the initial positions will make the word hang
          # off the edges of the canvas; if so, move it.
          x_0 = (@width - e[:width]) if x_0 + e[:width] > @width
          y_0 = (@height - e[:height]) if y_0 + e[:height] > @height

          # Set up our state
          x = x_0
          y = y_0
          theta = 0.0
          @image_png = ChunkyPNG::Image.from_file(@image.path)

          loop do
            if x > 0 && x < @width - e[:width] &&
               y > 0 && y < @height - e[:height] &&
               word_fits_at(word: word, extents: e, x: x, y: y)
              # It fits, so add the word to the canvas
              paint_word(word: word, size: size, x: x, y: y)

              # Reload the image now that we've painted on it
              @image_png = ChunkyPNG::Image.from_file(@image.path)

              # Correct from our top-right gravity to PDF bottom-right gravity, and
              # return the position of the text baseline, not the top-left corner
              return [x, @height - y - e[:ascent]]
            end

            # Loop until we make sure we have a point on the canvas
            theta += 0.1
            x = (x_0 + ((8.0 * theta * Math.cos(theta)) / (2 * Math::PI))).round
            y = (y_0 + ((8.0 * theta * Math.sin(theta)) / (2 * Math::PI))).round

            # Freak out if we've left the image entirely
            next unless 8.0 * theta > ([@width, @height].max * 1.8)

            x = x_0
            y = y_0 = Random.rand(@height).round
            theta = 0.0
          end
        end

        # Write out the canvas image to the `tmp` folder.
        #
        # Call this only when you need to debug the performance of the word
        # cloud algorithm.
        #
        # @return [void]
        # :nocov:
        def debug
          @image.write(Rails.root.join('tmp', 'debug.png'))
        end
        # :nocov:

        private

        # Set the `@width` and `@height` instance variables to best guesses.
        #
        # We basically rectangle-pack the words, to get an idea of how much
        # space they'll take up, then add a little bonus space to make sure we
        # can successfully build the image.
        #
        # @return [void]
        def calculate_canvas_size
          sizes = @extents.values
          sizes.sort! do |a, b|
            diff = [b[:width], b[:height]].max <=>
                   [a[:width], a[:height]].max
            diff = [b[:width], b[:height]].min <=>
                   [a[:width], a[:height]].min if diff.zero?
            diff = b[:height] <=> a[:height] if diff.zero?
            diff = b[:width] <=> a[:width] if diff.zero?
            diff
          end

          root = { x: 0, y: 0,
                   width: sizes[0][:width], height: sizes[0][:height] }

          sizes.each do |s|
            if (node = find_node(root: root, width: s[:width],
                                 height: s[:height]))
              split_node(node: node, width: s[:width], height: s[:height])
            else
              root = grow(root: root, width: s[:width], height: s[:height])
              redo
            end
          end

          @width = (root[:width] * 1.7).ceil
          @height = (root[:height] * 1.15).ceil
        end

        # Make a brand new PNG image with MiniMagick
        #
        # There's no API for making an image from scratch using MiniMagic. This
        # calls `convert` directly to make a new white PNG of the given
        # dimensions, then loads it with MiniMagick.
        #
        # @param [Integer] width the width of the image
        # @param [Integer] height the height of the image
        # @return [MiniMagic::Image] the newly created image
        def create_new_image(width:, height:)
          tempfile = Tempfile.new(['wordcloud', '.png'])
          MiniMagick::Tool::Convert.new do |new_image|
            new_image.size "#{width}x#{height}"
            new_image << 'xc:white'
            new_image << tempfile.path
          end

          # Don't GC these until this class is destroyed
          @tempfiles ||= []
          @tempfiles << tempfile

          MiniMagick::Image.new(tempfile.path)
        end

        # See if the word fits at the given location
        #
        # This checks the data in the `@clip_pngs` array to see if placing
        # the given word at the given location on the canvas would overlap any
        # words that are already there.
        #
        # @param [String] word the word to check
        # @param [Hash] extents the extents of this word
        # @param [Integer] x the x coordinate to check
        # @param [Integer] y the y coordinate to check
        # @return [Boolean] true if the word can fit without overlap
        def word_fits_at(word:, extents:, x:, y:)
          w = extents[:width].ceil + 10
          h = extents[:height].ceil + 10

          # If we're near the edge of the canvas, we can't just take a 5-pixel
          # pad around the image in all directions
          x_off = 0
          y_off = 0

          # Whether one of these edge conditions is triggered is stochastic, so
          # skip them for coverage
          # :nocov:
          if x < 5
            x_off = (5 - x)
            w -= x_off
          end
          if y < 5
            y_off = (5 - y)
            h -= y_off
          end
          # :nocov:

          w = @width - x + (5 - x_off) if x - (5 - x_off) + w > @width
          h = @height - y + (5 - y_off) if y - (5 - y_off) + h > @height

          clip_png = @clip_pngs[word]

          # Compare the pixels to check for overlap
          (0...h).each do |j|
            (0...w).each do |i|
              clip_color = clip_png[x_off + i, y_off + j]
              canvas_color = @image_png[x - (5 - x_off) + i, y - (5 - y_off) + j]

              if ChunkyPNG::Color.r(clip_color) < 255 &&
                 ChunkyPNG::Color.r(canvas_color) < 255
                return false
              end
            end
          end

          true
        end

        # Paint a word onto the canvas
        #
        # Once a word is in the right position, we paint it on the canvas for
        # good.
        #
        # @param [String] word the word to paint
        # @param [Integer] size the point size for the word
        # @param [Integer] x the x coordinate at which to paint
        # @param [Integer] y the y coordinate at which to paint
        # @return [void]
        def paint_word(word:, size:, x:, y:)
          @image.combine_options do |b|
            b.font(@font_path).pointsize(size)
            b.stroke('black').strokewidth(1).gravity('NorthWest')

            b.draw("text #{x},#{y} \"#{word}\"")
          end
        end

        # Get the width and height in pixels, as well as the ascender height
        # for this word.
        #
        # @param [String] word the word to get extents for
        # @param [Integer] size the size of the font to render
        # @return [Hash] a hash with keys `:width` and `:height` (the pixel
        #   size of the entire word) and `:ascent` (the distance from the top
        #   of the bounding box to the baseline)
        def get_word_extents(word:, size:)
          script = <<-MSL
<?xml version="1.0" encoding="UTF-8"?>
<image>
  <query-font-metrics text=#{word.encode(xml: :attr)} font=#{@font_path.encode(xml: :attr)} pointsize="#{size}" />
  <print output="%[msl:font-metrics.width] %[msl:font-metrics.height] %[msl:font-metrics.ascent]\\n" />
</image>
MSL

          temp = Tempfile.new('out.msl')
          temp.write(script)
          temp.close

          output = MiniMagick::Tool::Conjure.new(whiny: false) do |b|
            b << temp.path
          end

          temp.unlink

          numbers = output.split(' ').map(&:to_f)

          { width: numbers[0], height: numbers[1], ascent: numbers[2] }
        end

        # Find a node with sufficient space for a block of size wxh.
        #
        # @param [Hash] root the current node to check
        # @param [Integer] w the width of the block we're trying to place
        # @param [Integer] h the height of the block we're trying to place
        # @return [Hash] the node where this block fits
        def find_node(root:, width:, height:)
          if root[:used]
            find_node(root: root[:right], width: width, height: height) ||
              find_node(root: root[:down], width: width, height: height)
          elsif (width <= root[:width]) && (height <= root[:height])
            root
          end
        end

        # Create new nodes to the right and down from this node, consuming the
        # given space.
        #
        # @param [Hash] node the node to split
        # @param [Integer] width the width of the block to consume
        # @param [Integer] height the height of the block to consume
        # @return [void]
        def split_node(node:, width:, height:)
          node[:used] = true
          node[:down] = { x: node[:x],
                          y: node[:y] + height,
                          width: node[:width],
                          height: node[:height] - height }
          node[:right] = { x: node[:x] + width,
                           y: node[:y],
                           width: node[:width] - width,
                           height: node[:height] }
        end

        # Make the root node larger when we run out of space to place a block
        #
        # @param [Hash] root the root node
        # @param [Integer] width the width of the block we need to accommodate
        # @param [Integer] height the height of the block we need to
        #   accommodate
        # @return [Hash] the new root node (containing the current root)
        def grow(root:, width:, height:)
          can_grow_down = (width <= root[:width])
          can_grow_right = (height <= root[:height])

          should_grow_right = can_grow_right &&
                              (root[:height] >= (root[:width] + width))
          should_grow_down = can_grow_down &&
                             (root[:width] >= (root[:height] + height))

          # Where the thing can actually grow is stochastic; skip coverage
          # :nocov:
          if should_grow_right
            grow_right(root: root, width: width)
          elsif should_grow_down
            grow_down(root: root, height: height)
          elsif can_grow_right
            grow_right(root: root, width: width)
          elsif can_grow_down
            grow_down(root: root, height: height)
          else
            fail "Can't fit #{width}x#{height} into root, shouldn't happen"
          end
          # :nocov:
        end

        # Make the root node larger by growing to the right.
        #
        # @param [Hash] root the current root node
        # @param [Integer] width the width of the block we need to accommodate
        # @return [Hash] the new root node (containing the current root)
        def grow_right(root:, width:)
          {
            used:  true,
            x: 0,
            y: 0,
            width: root[:width] + width,
            height: root[:height],
            down: root,
            right: { x: root[:width], y: 0,
                     width: width, height: root[:height] }
          }
        end

        # Make the root node larger by growing down.
        #
        # @param [Hash] root the current root node
        # @param [Integer] height the height of the block we need to accommodate
        # @return [Hash] the new root node (containing the current root)
        def grow_down(root:, height:)
          {
            used:  true,
            x: 0,
            y: 0,
            width: root[:width],
            height: root[:height] + height,
            down: { x: 0, y: root[:height],
                    width: root[:width], height: height },
            right: root
          }
        end
      end
    end
  end
end
