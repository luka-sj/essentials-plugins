#===============================================================================
#  Base component for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Base < ::LUTS::Sprites::Base
      attr_reader :backdrop
      #-------------------------------------------------------------------------
      #  basic sprite component
      #-------------------------------------------------------------------------
      def initialize(viewport, data, room)
        @viewport = viewport
        @data     = data
        @room     = room
        @backdrop = @room.sprites.hash.backdrop
        super(@viewport)

        set_bitmap("Graphics/Battlebacks/Bases/#{data}")
        anchor(:bottom_middle)
        self.ex = backdrop.ox
        self.ey = backdrop.bitmap.height
      end
      #-------------------------------------------------------------------------
      #  position components relative to room
      #-------------------------------------------------------------------------
      def position
        position_zoom
        position_coordinates
      end

      def position_zoom
        self.zoom_x = backdrop.zoom_x * (zx || 1)
        self.zoom_y = backdrop.zoom_y * (zy || 1)
      end

      def position_coordinates
        self.x = backdrop.x - (backdrop.ox - ex) * backdrop.zoom_x
        self.y = backdrop.y - (backdrop.oy - ey) * backdrop.zoom_y
      end
      #-------------------------------------------------------------------------
    end
  end
end
