#===============================================================================
#  Weather components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Weather
      class Snow
        include SCBA::Common::Room

        attr_accessor :harsh
        #-----------------------------------------------------------------------
        #  weather particle constructor
        #-----------------------------------------------------------------------
        def construct
          @min_pos = backdrop.bitmap.height / 4
          @max_pos = backdrop.bitmap.height / 2

          72.times do |i|
            @sprites.add(
              i,
              bitmap: 'Graphics/Battlebacks/Components/snow',
              anchor: :middle,
              opacity: 0
            )
          end
        end
        #-----------------------------------------------------------------------
        #  update weather particles
        #-----------------------------------------------------------------------
        def update
          72.times do |i|
            reset_particle(i) if @sprites[i].opacity <= 0

            scale = (2 * Math::PI) / ((@sprites[i].bitmap.width / 64.0) * (@max_pos - @min_pos) + @min_pos)
            @sprites[i].opacity -= @sprites[i].speed.lerp * (harsh ? 1 : 0.5)
            @sprites[i].ey      += @sprites[i].speed.lerp * (harsh ? 1 : 0.5)
            @sprites[i].ex       = @sprites[i].end_x + @sprites[i].bitmap.width * 0.25 * Math.sin(@sprites[i].ey * scale) * @sprites[i].toggle
          end
        end

        def position_zoom; end

        private
        #-----------------------------------------------------------------------
        #  reset particle position
        #-----------------------------------------------------------------------
        def reset_particle(i)
          z = rand(32)
          @sprites[i].param   = 0.24 + 0.01 * rand(z / 2)
          @sprites[i].ey      = -rand(64)
          @sprites[i].ex      = 32 + rand(backdrop.bitmap.width - 64)
          @sprites[i].end_x   = @sprites[i].ex
          @sprites[i].toggle  = rand(2).zero? ? 1 : -1
          @sprites[i].speed   = 1 + 2 / (rand(1...6) * 0.4)
          @sprites[i].z       = z - (@room.focused? ? 0 : 100)
          @sprites[i].opacity = 255
        end
        #-----------------------------------------------------------------------
      end
    end
  end
end
