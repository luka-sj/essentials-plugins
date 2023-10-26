#===============================================================================
#  Background component for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Backdrop < ::LUTS::Sprites::Base
      #-------------------------------------------------------------------------
      #  basic sprite component
      #-------------------------------------------------------------------------
      def initialize(viewport, data, room)
        @viewport = viewport
        @data     = data
        @room     = room
        super(@viewport)

        set_bitmap("Graphics/Battlebacks/Backdrops/#{data}")
      end
      #-------------------------------------------------------------------------
    end
  end
end
