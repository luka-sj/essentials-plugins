#===============================================================================
#  Water components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Water
      include SCBA::Common::Room
      #-------------------------------------------------------------------------
      #  particle constructor
      #-------------------------------------------------------------------------
      def construct
        2.times do |i|
          @sprites.add(
            i,
            type: 'Scrolling',
            bitmap: "Graphics/Battlebacks/Components/water#{i}",
            speed: 0.5,
            direction: 1,
            ex: 0,
            ey: 146,
            param: 1,
            mirror: i > 0
          )
        end
      end
      #-------------------------------------------------------------------------
    end
  end
end
