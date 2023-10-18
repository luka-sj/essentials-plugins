#===============================================================================
#  Weather components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    module Weather
      class Rain
        include SCBA::Common::Room

        attr_accessor :harsh
        #-----------------------------------------------------------------------
        #  weather particle constructor
        #-----------------------------------------------------------------------
        def construct
          72.times do |i|
            @sprites.add(
              i,
              create_rect: [(harsh ? 28 : 24), 3, Color.white],
              angle: 80,
              oy: 2,
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

            @sprites[i].opacity -= @sprites[i].speed.lerp * (harsh ? 2 : 1.5)
            @sprites[i].end_x   += @sprites[i].speed.lerp * (harsh ? 4 : 2)
            @sprites[i].ox       = @sprites[i].end_x
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
          @sprites[i].ox      = 0
          @sprites[i].end_x   = 0.0
          @sprites[i].ey      = -rand(64)
          @sprites[i].ex      = 32 + rand(backdrop.bitmap.width - 64)
          @sprites[i].speed   = 3 + 2 / (rand(1...6) * 0.4)
          @sprites[i].z       = z - (@room.focused? ? 0 : 100)
          @sprites[i].opacity = 255
        end
        #-----------------------------------------------------------------------
      end
    end
  end
end
