#===============================================================================
#  Light B components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Lights
      class B
        include SCBA::Common::Room
        #-----------------------------------------------------------------------
        #  particle constructor
        #-----------------------------------------------------------------------
        def construct
          @opacity = [128, 179, 230, 255]
          bitmap   = "Graphics/Battlebacks/Components/#{@data.is_a?(String) ? @data : 'lightB'}"

          6.times do |i|
            @sprites.add(
              i,
              bitmap: bitmap,
              anchor: :top_middle,
              ex: [40, 104, 146, 210, 256, 320][i],
              ey: -8,
              mirror: (i % 2).odd?,
              speed: rand(2...5) * 3,
              z: 3,
              opacity: 0,
              memorize_bitmap: true
            )
          end
        end
        #-----------------------------------------------------------------------
        #  update light particles
        #-----------------------------------------------------------------------
        def update
          4.times do |i|
            @sprites[i].update
            next unless (@room.frame % @sprites[i].speed.lerp(inverse: true)) < 1

            @sprites[i].bitmap = @sprites[i].stored_bitmap.clone
            @sprites[i].bitmap.hue_change((rand(8) * 45).lerp.round)
            @sprites[i].opacity = (rand(4) < 2 ? 192 : 0)
          end
        end
        #-----------------------------------------------------------------------
      end
    end
  end
end
