# frozen_string_literal: true
require 'sdl'

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

          SDL::TTF.init unless SDL::TTF.init?

          # Render each word to a PNG that we'll use to check whether words
          # overlap
          @clip_surfaces = words.each_with_object({}) do |(word, size), ret|
            ret[word] = font_for(size).render_solid_utf8(word, 0, 0, 0)
          end

          # Take a guess at how much area we'll need to build the image
          calculate_canvas_size

          # Build the image where we'll store the clipping data
          big_endian = ([1].pack("N") == [1].pack("L"))
          if big_endian
            rmask = 0xff000000
            gmask = 0x00ff0000
            bmask = 0x0000ff00
          else
            rmask = 0x000000ff
            gmask = 0x0000ff00
            bmask = 0x00ff0000
          end

          @image = SDL::Surface.new(SDL::SWSURFACE, @width, @height, 24,
                                    rmask, gmask, bmask, 0)
          @image.fill_rect(0, 0, @width, @height, @image.format.map_rgb(0, 0, 0))
        end

        # Place a word on the canvas, not overlapping with any others
        #
        # @param [String] word the word to place
        # @param [Integer] size the point size for the word
        # @return [void]
        def place_word(word:, size:)
          font = font_for(size)
          ascent = font.ascent
          dimen = font.text_size(word)

          # Start at a random position on the center line
          x_0 = ((@width - dimen[0]) / 2.0).round
          y_0 = Random.rand(@height).round

          # It's possible that the initial positions will make the word hang
          # off the edges of the canvas; if so, move it.
          x_0 = (@width - dimen[0]) if x_0 + dimen[0] > @width
          y_0 = (@height - dimen[1]) if y_0 + dimen[1] > @height

          # Set up our state
          x = x_0
          y = y_0
          theta = 0.0

          loop do
            if x > 0 && x < @width - dimen[0] &&
               y > 0 && y < @height - dimen[1] &&
               word_fits_at(word: word, x: x, y: y)
              # It fits, so add the word to the canvas
              paint_word(word: word, size: size, x: x, y: y)

              # Correct from our top-right gravity to PDF bottom-right gravity, and
              # return the position of the text baseline, not the top-left corner
              return [x, @height - y - ascent]
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
          sizes = @clip_surfaces.map do |s|
            { width: s[1].w, height: s[1].h }
          end

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

        # See if the word fits at the given location
        #
        # This checks the data in the `@clip_surfaces` array to see if placing
        # the given word at the given location on the canvas would overlap any
        # words that are already there.
        #
        # @param [String] word the word to check
        # @param [Integer] x the x coordinate to check
        # @param [Integer] y the y coordinate to check
        # @return [Boolean] true if the word can fit without overlap
        def word_fits_at(word:, x:, y:)
          clip_surface = @clip_surfaces[word]
          w = clip_surface.w
          h = clip_surface.h

          # Compare the pixels to check for overlap
          (0...h).each do |j|
            (0...w).each do |i|
              clip_color = clip_surface.get_pixel(i, j)
              canvas_color = @image.get_pixel(x + i, y + j)

              return false if clip_color != 0 && canvas_color != 0
            end
          end

          true
        end

        def font_for(size)
          font = SDL::TTF.open(@font_path, size)
          font.style = SDL::TTF::STYLE_NORMAL

          font
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
          font_for(size).draw_blended_utf8(@image, word, x, y, 255, 255, 255)
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
