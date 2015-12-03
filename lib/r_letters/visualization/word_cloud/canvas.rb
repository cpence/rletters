
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
        def initialize(words, font_path)
          @font_path = font_path

          # Get the size of the bounding box for each word
          @extents = words.each_with_object({}) do |(word, size), ret|
            ret[word] = get_word_extents(word, size)
          end

          # Render each word to a PNG that we'll use to check whether words
          # overlap
          @clip_pngs = words.each_with_object({}) do |(word, size), ret|
            e = @extents[word]

            clip_image = create_new_image(e[:w].ceil + 10, e[:h].ceil + 10)
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
          @image = create_new_image(@width, @height)
        end

        # Place a word on the canvas, not overlapping with any others
        #
        # @param [String] word the word to place
        # @param [Integer] size the point size for the word
        # @return [void]
        def place_word(word, size)
          e = @extents[word]

          # Start at a random position on the center line
          x_0 = ((@width - e[:w]) / 2.0).round
          y_0 = Random.rand(@height).round

          # It's possible that the initial positions will make the word hang
          # off the edges of the canvas; if so, move it.
          x_0 = (@width - e[:w])  if x_0 + e[:w] > @width
          y_0 = (@height - e[:h]) if y_0 + e[:h] > @height

          # Set up our state
          x = x_0
          y = y_0
          theta = 0.0
          @image_png = ChunkyPNG::Image.from_file(@image.path)

          loop do
            if x > 0 && x < @width - e[:w] &&
               y > 0 && y < @height - e[:h] &&
               word_fits_at(word, e, x, y)
              # It fits, so add the word to the canvas
              paint_word(word, size, x, y)

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
            diff = [b[:w], b[:h]].max <=> [a[:w], a[:h]].max
            diff = [b[:w], b[:h]].min <=> [a[:w], a[:h]].min if diff.zero?
            diff = b[:h] <=> a[:h] if diff.zero?
            diff = b[:w] <=> a[:w] if diff.zero?
            diff
          end

          root = { x: 0, y: 0, w: sizes[0][:w], h: sizes[0][:h] }

          sizes.each do |s|
            if (node = find_node(root, s[:w], s[:h]))
              split_node(node, s[:w], s[:h])
            else
              root = grow(root, s[:w], s[:h])
              redo
            end
          end

          @width = (root[:w] * 1.7).ceil
          @height = (root[:h] * 1.15).ceil
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
        def create_new_image(width, height)
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
        def word_fits_at(word, extents, x, y)
          w = extents[:w].ceil + 10
          h = extents[:h].ceil + 10

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
        def paint_word(word, size, x, y)
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
        # @return [Hash] a hash with keys `:w` and `:h` (the pixel size of the
        #   entire word) and `:ascent` (the distance from the top of the
        #   bounding box to the baseline)
        def get_word_extents(word, size)
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

          output = MiniMagick::Tool::Conjure.new(false) do |b|
            b << temp.path
          end

          temp.unlink

          numbers = output.split(' ').map(&:to_f)

          { w: numbers[0], h: numbers[1], ascent: numbers[2] }
        end

        # Find a node with sufficient space for a block of size wxh.
        #
        # @param [Hash] root the current node to check
        # @param [Integer] w the width of the block we're trying to place
        # @param [Integer] h the height of the block we're trying to place
        # @return [Hash] the node where this block fits
        def find_node(root, w, h)
          if root[:used]
            find_node(root[:right], w, h) || find_node(root[:down], w, h)
          elsif (w <= root[:w]) && (h <= root[:h])
            root
          end
        end

        # Create new nodes to the right and down from this node, consuming the
        # given space.
        #
        # @param [Hash] node the node to split
        # @param [Integer] w the width of the block to consume
        # @param [Integer] h the height of the block to consume
        # @return [void]
        def split_node(node, w, h)
          node[:used]  = true
          node[:down]  = { x: node[:x],
                           y: node[:y] + h,
                           w: node[:w],
                           h: node[:h] - h }
          node[:right] = { x: node[:x] + w,
                           y: node[:y],
                           w: node[:w] - w,
                           h: node[:h] }
        end

        # Make the root node larger when we run out of space to place a block
        #
        # @param [Hash] root the root node
        # @param [Integer] w the width of the block we need to accommodate
        # @param [Integer] h the height of the block we need to accommodate
        # @return [Hash] the new root node (containing the current root)
        def grow(root, w, h)
          can_grow_down = (w <= root[:w])
          can_grow_right = (h <= root[:h])

          should_grow_right = can_grow_right && (root[:h] >= (root[:w] + w))
          should_grow_down = can_grow_down && (root[:w] >= (root[:h] + h))

          # Where the thing can actually grow is stochastic; skip coverage
          # :nocov:
          if should_grow_right
            grow_right(root, w, h)
          elsif should_grow_down
            grow_down(root, w, h)
          elsif can_grow_right
            grow_right(root, w, h)
          elsif can_grow_down
            grow_down(root, w, h)
          else
            fail "Can't fit #{w}x#{h} into root, shouldn't happen"
          end
          # :nocov:
        end

        # Make the root node larger by growing to the right.
        #
        # @param [Hash] root the current root node
        # @param [Integer] w the width of the block we need to accommodate
        # @param [Integer] h the height of the block we need to accommodate
        # @return [Hash] the new root node (containing the current root)
        def grow_right(root, w, _)
          {
            used:  true,
            x:     0,
            y:     0,
            w:     root[:w] + w,
            h:     root[:h],
            down:  root,
            right: { x: root[:w], y: 0, w: w, h: root[:h] }
          }
        end

        # Make the root node larger by growing down.
        #
        # @param [Hash] root the current root node
        # @param [Integer] w the width of the block we need to accommodate
        # @param [Integer] h the height of the block we need to accommodate
        # @return [Hash] the new root node (containing the current root)
        def grow_down(root, _, h)
          {
            used:  true,
            x:     0,
            y:     0,
            w:     root[:w],
            h:     root[:h] + h,
            down:  { x: 0, y: root[:h], w: root[:w], h: h },
            right: root
          }
        end
      end
    end
  end
end
