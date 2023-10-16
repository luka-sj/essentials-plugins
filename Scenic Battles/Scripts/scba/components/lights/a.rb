#===============================================================================
#  Light A components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Lights
      class A
        include SCBA::Common::Room
        #-------------------------------------------------------------------------
        #  particle constructor
        #-------------------------------------------------------------------------
        def construct
          @opacity = [128, 179, 230, 255]
          bitmap   = "Graphics/Battlebacks/Components/#{@data.is_a?(String) ? @data : 'lightA'}"

          4.times do |i|
            @sprites.add(
              i,
              bitmap: bitmap,
              ex: [183, 135, 70, 0][i],
              ey: [-2, -15, -15, -16][i],
              param: [0.8, 1, 1.25, 1.4][i],
              z: [10, 10, 18, 18][i],
              opacity: [0.5, 0.7, 0.9, 1][i] * 255,
              end_x: [0.5, 0.7, 0.9, 1][i],
              speed: rand(1...5)
            )
          end
        end
        #-------------------------------------------------------------------------
        #  update light particles
        #-------------------------------------------------------------------------
        def update
          4.times do |i|
            @sprites[i].update
            @opacity[i] -= (@sprites[i].toggle * @sprites[i].speed).lerp
            @sprites[i].opacity = @opacity[i]
            @sprites[i].toggle *= -1 if @sprites[i].opacity <= 95 || @sprites[i].opacity >= @sprites[i].end_x * 255
          end
        end
        #-------------------------------------------------------------------------
      end
    end
  end
end
