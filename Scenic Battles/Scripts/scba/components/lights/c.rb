#===============================================================================
#  Light C components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Lights
      class C
        include SCBA::Common::Room
        #-----------------------------------------------------------------------
        #  particle constructor
        #-----------------------------------------------------------------------
        def construct
          @opacity = []
          8.times do |i|
            var    = [2, 3, 1, 3, 2, 3, 1, 3][i]
            opc    = rand(50..100) / 100.0
            bitmap = "Graphics/Battlebacks/Components/lightC#{var}"

            @sprites.add(
              i,
              bitmap: bitmap,
              ex: [-2, 10, 40, 60, 100, 118, 160, 168][i],
              ey: [-22, -46, -8, -32, -14, -40, 0, -58][i],
              z: 10,
              opacity: opc * 255,
              end_x: opc,
              speed: rand(1...5)
            )
            @opacity << opc * 255
          end
        end
        #-----------------------------------------------------------------------
        #  update light particles
        #-----------------------------------------------------------------------
        def update
          8.times do |i|
            @sprites[i].update
            @opacity[i] -= (@sprites[i].toggle * 0.75).lerp
            @sprites[i].opacity = @opacity[i]
            @sprites[i].toggle *= -1 if @sprites[i].opacity <= 95 || @sprites[i].opacity >= @sprites[i].end_x * 255
          end
        end
        #-----------------------------------------------------------------------
      end
    end
  end
end
