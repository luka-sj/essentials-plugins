#===============================================================================
#  Vacuum (animation) components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Vacuum
      include SCBA::Common::Room
      #-------------------------------------------------------------------------
      #  particle constructor
      #-------------------------------------------------------------------------
      def construct
        img = @data.is_a?(String) ? @data : 'dark004'

        3.times do |i|
          @sprites.add(
            i,
            bitmap: "Graphics/Battlebacks/Components/#{img}",
            anchor: :middle,
            ex: 234,
            ey: 128,
            param: 1.5,
            opacity: 0,
            z: 1
          )
        end
      end
      #-------------------------------------------------------------------------
      #  animate vacuum particles
      #-------------------------------------------------------------------------
      def update
        3.times do |i|
          next if i > @room.frame / 50.lerp

          if @sprites[i].param <= 0
            @sprites[i].param = 1.5
            @sprites[i].opacity = 0
            @sprites[i].ex = 234
          end

          @sprites[i].opacity += (@sprites[i].param < 0.75 ? -4 : 4).lerp
          @sprites[i].ex += [1, 2.lerp].max if (@room.frame % 4.lerp).zero? && @sprites[i].ex < 284
          @sprites[i].ey -= [1, 2.lerp].min if (@room.frame % 4.lerp).zero? && @sprites[i].ey > 108
          @sprites[i].param -= 0.01.lerp
        end
      end
      #-------------------------------------------------------------------------
      #  calculate sprite positions
      #-------------------------------------------------------------------------
      def position_zoom
        @sprites.each do |_key, sprite|
          sprite.zoom_x = sprite.param * backdrop.zoom_x
          sprite.zoom_y = sprite.param * backdrop.zoom_x
        end
      end
      #-------------------------------------------------------------------------
    end
  end
end
