#===============================================================================
#  Luka's Scripting Utilities
#
#  Sheet sprite class for new sprite engine
#===============================================================================
module Sprites
  class Sheet < Base
    # @return [Integer]
    attr_reader   :cur_frame
    # @return [NUmeric]
    attr_accessor :speed

    # Sets default attribute values
    def default!
      super
      @frames    = 1
      @speed     = 1
      @cur_frame = 0
      @vertical  = false
    end

    # Sets sprite bitmap
    # @param file [String]
    # @param frames [Integer]
    # @param vertical [Boolean]
    # @param speed [Numeric]
    def set_bitmap(file, frames: 1, vertical: false, speed: @speed)
      @speed    = speed
      @frames   = frames
      @vertical = vertical

      self.bitmap = SpriteHash.bitmap(file)

      if @vertical
        src_rect.height /= @frames
      else
        src_rect.width /= @frames
      end
    end

    # Updates sprite animation
    def update
      return unless bitmap

      if @cur_frame.lerp >= @speed
        if @vertical
          src_rect.y += src_rect.height
          src_rect.y = 0 if src_rect.y >= bitmap.height
        else
          src_rect.x += src_rect.width
          src_rect.x = 0 if src_rect.x >= bitmap.width
        end
        @cur_frame = 0
      end
      @cur_frame += 1
    end
  end
end
