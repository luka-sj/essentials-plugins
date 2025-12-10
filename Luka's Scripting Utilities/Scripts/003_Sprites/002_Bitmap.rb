#===============================================================================
#  Luka's Scripting Utilities
#
#  Base bitmap class for new sprite engine
#===============================================================================
module Sprites
  class Bitmap < ::Bitmap
    # @return [String]
    attr_accessor :path

    # @param args [Array<String, Integer]
    # @param block [Proc]
    def initialize(*args, &block)
      @path = args.first if args.first.is_a?(String)

      super(*args)
      block.call(self) if block_given?
    end

    # Draws circle on bitmap
    # @param color [Color]
    # @param radius [Integer]
    # @param hollow [Boolean] if circle should be filled in
    def draw_circle(color, radius:, hollow: false)
      # basic circle formula
      # (x - center_x)**2 + (y - center_y)**2 = r**2
      width.times do |x|
        f = (radius**2 - (x - width / 2)**2)
        next if f.negative?

        y1 = -Math.sqrt(f).to_i + height / 2
        y2 = Math.sqrt(f).to_i + height / 2

        if hollow
          set_pixel(x, y1, color)
          set_pixel(x, y2, color)
        else
          fill_rect(x, y1, 1, y2 - y1, color)
        end
      end
    end

    # Sets font parameters
    # @param name [String]
    # @param size [Integer]
    # @param bold [Boolean]
    def set_font(name:, size:, bold: false)
      font.name = name
      font.size = size
      font.bold = bold
    end

    # Applies mask on bitmap
    # @param mask [Bitmap]
    # @param offset_x [Integer]
    # @param offset_y [Integer]
    def mask!(mask = nil, offset_x: 0, offset_y: 0)
      bitmap = clone
      case mask
      when Bitmap
        mbmp = mask
      when Sprite
        mbmp = mask.bitmap
      when String
        mbmp = LUTS::Sprites.bitmap(mask)
      else
        return false
      end

      cbmp = Bitmap.new(mbmp.width, mbmp.height)
      mask = mbmp.clone
      ox = (bitmap.width - mbmp.width) / 2
      oy = (bitmap.height - mbmp.height) / 2
      width = mbmp.width + ox
      height = mbmp.height + oy

      (oy...height).each do |y|
        (ox...width).each do |x|
          pixel = mask.get_pixel(x - ox, y - oy)
          color = bitmap.get_pixel(x - offset_x, y - offset_y)
          alpha = pixel.alpha
          alpha = color.alpha if color.alpha < pixel.alpha

          cbmp.set_pixel(x - ox, y - oy, Color.new(color.red, color.green, color.blue, alpha))
        end
      end

      mask.dispose
      cbmp
    end

    # Swaps out specified colors (resource intensive, best not use on large sprites)
    # @param bmp [Bitmap]
    def swap_colors(bmp)
      map = {}.tap do |map_hash|
        bmp.width.times do |x|
          start = bmp.get_pixel(x, 0)
          final = bmp.get_pixel(x, 1)

          map_hash[[start.red, start.green, start.blue]] = [final.red, final.green, final.blue]
        end
      end
      # failsafe
      return unless map.is_a?(Hash)

      # iterate over sprite's pixels
      width.times do |x|
        height.times do |y|
          pixel = get_pixel(x, y)
          next if pixel.alpha.zero?

          final = nil
          map.each_key do |key|
            # check for key mapping
            target = Color.new(*key)
            final  = Color.new(*map[key]) if tolerance?(pixel, target)
          end
          # swap current pixel color with target
          set_pixel(x, y, final) if final.is_a?(Color)
        end
      end
    end

    # Applies tone to bitmap directly
    # @param tone [Tone]
    def apply_tone(tone)
      # Get raw pixel data
      pixels = raw_data.unpack('C*')

      # Process 4 pixels at a time (16 bytes) for better performance
      (0...pixels.length).step(16) do |i|
        # Bulk process multiple pixels
        end_idx = [i + 15, pixels.length - 1].min

        (i..end_idx).step(4) do |pixel_base|
          break if pixel_base + 2 >= pixels.length

          r, g, b = tone.lookup_table.transform(
            pixels[pixel_base],
            pixels[pixel_base + 1],
            pixels[pixel_base + 2]
          )

          pixels[pixel_base]     = r
          pixels[pixel_base + 1] = g
          pixels[pixel_base + 2] = b
        end
      end

      # Write modified data back to bitmap
      self.raw_data = pixels.pack('C*')
    end

    # @return [Boolean] pixel matches color tolerance
    # @param pixel [Color]
    # @param target [Color]
    def tolerance?(pixel, target)
      tol = 0.05

      return false unless pixel.red.between?(target.red - target.red * tol, target.red + target.red * tol)
      return false unless pixel.green.between?(target.green - target.green * tol, target.green + target.green * tol)
      return false unless pixel.blue.between?(target.blue - target.blue * tol, target.blue + target.blue * tol)

      true
    end

    # @return [Boolean] finished animating
    def finished?
      true
    end
  end
end
