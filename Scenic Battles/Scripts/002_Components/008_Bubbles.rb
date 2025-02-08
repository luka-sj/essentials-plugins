#===============================================================================
#  Bubble components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Bubbles
      include SCBA::Common::Room
      #-------------------------------------------------------------------------
      #  particle constructor
      #-------------------------------------------------------------------------
      def construct
        bitmap = "Graphics/Battlebacks/Components/#{@data.is_a?(String) ? @data : 'bubble'}"

        18.times do |i|
          @sprites.add(i, bitmap: bitmap, ey: -32, opacity: 0, 'center!': true)
        end
      end
      #-------------------------------------------------------------------------
      #  animate bubble particles
      #-------------------------------------------------------------------------
      def update
        @sprites.update

        18.times do |i|
          reset_params(i) if @sprites[i].ey <= -32

          min = backdrop.bitmap.height / 4
          max = backdrop.bitmap.height / 2
          scale = (2 * Math::PI) / ((@sprites[i].bitmap.width / 64.0) * (max - min) + min)
          @sprites[i].opacity += 4 if @sprites[i].opacity < @sprites[i].end_y
          @sprites[i].ey -= [1, @sprites[i].speed].max.lerp
          @sprites[i].ex = @sprites[i].end_x + @sprites[i].bitmap.width * 0.25 * Math.sin(@sprites[i].ey * scale) * @sprites[i].toggle
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

      private
      #-------------------------------------------------------------------------
      #  reset bubble particle position
      #-------------------------------------------------------------------------
      def reset_params(i)
        @sprites[i].param   = 0.16 + 0.01 * rand(32)
        @sprites[i].ey      = backdrop.bitmap.height * 0.25 + rand(backdrop.bitmap.height * 0.75)
        @sprites[i].ex      = rand(32...((backdrop.bitmap.width * backdrop.zoom_x).to_i - 64))
        @sprites[i].end_y   = rand(64...136)
        @sprites[i].end_x   = @sprites[i].ex
        @sprites[i].toggle  = rand(2).zero? ? 1 : -1
        @sprites[i].speed   = 1 + 2 / (rand(3...8) * 0.4)
        @sprites[i].z       = [2, 15, 25][rand(3)] + rand(6) - (@room.focused ? 0 : 100)
        @sprites[i].opacity = 0
      end
      #-------------------------------------------------------------------------
    end
  end
end
