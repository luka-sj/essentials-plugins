#===============================================================================
#  Weather components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Weather
      class HarshSun < Sun
        include SCBA::Common::Room

        def construct
          @harsh = true
          super
        end
      end
    end
  end
end
