#===============================================================================
#  Weather components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Weather
      class HeavyRain < Rain
        include SCBA::Common::Room

        def construct
          @harsh = true
          super
        end
      end
    end
  end
end
