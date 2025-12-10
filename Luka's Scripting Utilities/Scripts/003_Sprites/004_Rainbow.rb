#===============================================================================
#  Luka's Scripting Utilities
#
#  Rainbow sprite class for new sprite engine
#===============================================================================
module Sprites
  class Rainbow < Base
    # @return [Numeric]
    attr_accessor :speed

    # Sets sprite bitmap
    # @param path [String]
    # @param speed [Integer]
    def set_bitmap(path, speed: 1)
      @stored_bitmap = SpriteHash.bitmap(path)
      @speed         = speed
      @current_hue   = 0

      self.bitmap = ::Bitmap.new(@stored_bitmap.width, @stored_bitmap.height)
      bitmap.blt(0, 0, @stored_bitmap, @stored_bitmap.rect)
    end

    # Updates sprite animation
    def update
      @current_hue += @speed.lerp
      @current_hue  = 0 if @current_hue >= 360

      bitmap.clear
      bitmap.blt(0, 0, @stored_bitmap, @stored_bitmap.rect)
      bitmap.hue_change(@current_hue)
    end
  end
end
