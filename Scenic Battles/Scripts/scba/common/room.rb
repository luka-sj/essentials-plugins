#===============================================================================
#  Room positioning functionality
#===============================================================================
module SCBA
  module Common
    module Room
      attr_reader :backdrop, :sprites
      #-------------------------------------------------------------------------
      #  class constructor
      #-------------------------------------------------------------------------
      def initialize(viewport, data, room)
        @viewport = viewport
        @data     = data
        @room     = room
        @backdrop = room.sprites.hash.backdrop
        @sprites  = LUTS::SpriteHash.new(viewport)

        construct
      end

      def construct; end
      #-------------------------------------------------------------------------
      #  update all sprite components
      #-------------------------------------------------------------------------
      def update
        @sprites.update
      end
      #-------------------------------------------------------------------------
      #  dispose all particles
      #-------------------------------------------------------------------------
      def dispose
        @sprites.dispose
      end
      #-------------------------------------------------------------------------
      #  position components relative to room
      #-------------------------------------------------------------------------
      def position
        position_zoom
        position_coordinates
      end

      def position_zoom
        @sprites.each do |_key, sprite|
          sprite.zoom_x = backdrop.zoom_x * (sprite.zx || 1)
          sprite.zoom_y = backdrop.zoom_y * (sprite.zy || 1)
        end
      end

      def position_coordinates
        @sprites.each do |_key, sprite|
          sprite.x = backdrop.x - (backdrop.ox - sprite.ex) * backdrop.zoom_x
          sprite.y = backdrop.y - (backdrop.oy - sprite.ey) * backdrop.zoom_y
        end
      end
      #-------------------------------------------------------------------------
    end
  end
end
