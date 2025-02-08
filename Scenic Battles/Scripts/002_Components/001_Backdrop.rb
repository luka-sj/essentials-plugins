#===============================================================================
#  Background component for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Backdrop < ::Sprites::Base
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
