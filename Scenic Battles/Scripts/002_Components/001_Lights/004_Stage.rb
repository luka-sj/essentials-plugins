#===============================================================================
#  Stage lights components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Lights
      class Stage
        include SCBA::Common::Room
        #-----------------------------------------------------------------------
        #  particle constructor
        #-----------------------------------------------------------------------
        def construct
          2.times do |i|
            @sprites.add(
              i,
              type: :sheet,
              bitmap: {
                file: 'Graphics/Battlebacks/Components/lightDecor',
                frames: 12
              },
              anchor: :middle,
              z: 1,
              zx: 1 * [2.5, 1.25][i],
              zy: 0.35 * [2.5, 1][i],
              ex: [64, 256][i],
              ey: [256, 178][i], # 148
              speed: 2
            )
          end
        end
      end
    end
  end
end
