#===============================================================================
#  Weather components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Weather
      class StrongWinds
        include SCBA::Common::Room

        def construct
          @room.strong_wind = true
        end

        def dispose
          @room.strong_wind = false
        end
      end
    end
  end
end
