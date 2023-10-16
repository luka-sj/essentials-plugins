#===============================================================================
#  Extensions for the `Bitmap` class
#===============================================================================
module LUTS
  module Sprites
    class Bitmap < ::Bitmap
      #-------------------------------------------------------------------------
      attr_accessor :stored_path
      #-------------------------------------------------------------------------
      #  draws circle on bitmap
      #-------------------------------------------------------------------------
      def draw_circle(color, radius:, hollow: false)
        # basic circle formula
        # (x - center_x)**2 + (y - center_y)**2 = r**2
        width.times do |x|
          f = (radius**2 - (x - width / 2)**2)
          next if f < 0

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
      #-------------------------------------------------------------------------
      #  sets font parameters
      #-------------------------------------------------------------------------
      def set_font(name:, size:, bold: false)
        font.name = name
        font.size = size
        font.bold = bold
      end
      #-------------------------------------------------------------------------
      #  swap out specified colors (resource intensive, best not use on large sprites)
      #-------------------------------------------------------------------------
      def swap_colors(map)
        # check for a potential bitmap map
        if map.is_a?(Bitmap)
          bmp = map.clone
          map = {}
          map = {}.tap do |map_hash|
            bmp.width.times do |x|
              map_hash[bmp.get_pixel(x, 0).to_hex] = bmp.get_pixel(x, 1).to_hex
            end
          end
        end
        # failsafe
        return unless map.is_a?(Hash)

        # iterate over sprite's pixels
        width.times do |x|
          height.times do |y|
            pixel = get_pixel(x, y)
            final = nil
            map.keys.each do |key|
              # check for key mapping
              target = Color.parse(key)
              final  = Color.parse(map[key]) if target.eql?(pixel)
            end
            # swap current pixel color with target
            set_pixel(x, y, final) if final && final.is_a?(Color)
          end
        end
      end
      #-------------------------------------------------------------------------
    end
  end
end
