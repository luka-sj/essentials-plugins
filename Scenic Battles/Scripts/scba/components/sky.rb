#===============================================================================
#  Sky component for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Sky
      include SCBA::Common::Room

      attr_accessor :rain
      #-------------------------------------------------------------------------
      #  particle constructor
      #-------------------------------------------------------------------------
      def construct
        @tone_color = 0.0
        @tone_gray  = 0.0

        draw_background
        draw_clouds
        draw_stars
        draw_sun
      end
      #-------------------------------------------------------------------------
      #  animate skybox
      #-------------------------------------------------------------------------
      def update
        update_sky_tone
        # apply sky tone to appropriate sprites
        @sprites.hash.box.tone.all  = @tone_color
        @sprites.hash.box.tone.gray = @tone_gray
        2.times do |i|
          key = "cloud_#{i}".to_sym
          @sprites[key].tone.all  = @tone_color
          @sprites[key].tone.gray = @tone_gray
        end

        @sprites.update
        update_stars
      end
      #-------------------------------------------------------------------------
      #  calculate sprite positions
      #-------------------------------------------------------------------------
      def position_zoom
        @sprites.each do |key, sprite|
          if key.eql?(:box)
            super
            next
          end

          sprite.zoom_x = sprite.param * backdrop.zoom_x
          sprite.zoom_y = sprite.param * backdrop.zoom_x
        end
      end

      private
      #-------------------------------------------------------------------------
      #  render skybox
      #-------------------------------------------------------------------------
      def draw_background
        key = 'Day'
        if @room.outdoor?
          key = 'Dawn' if PBDayNight.isEvening? || PBDayNight.isMorning?
          key = 'Night' if PBDayNight.isNight?
        end

        @sprites.add(:box, bitmap: "Graphics/Battlebacks/Components/sky#{key}", anchor: :bottom_left)
        @sprites.hash.box.ey = @sprites.hash.box.oy
      end
      #-------------------------------------------------------------------------
      #  render individual cloud sprites
      #-------------------------------------------------------------------------
      def draw_clouds
        [1, 0].each do |i|
          @sprites.add(
            "cloud_#{i}".to_sym,
            type: :scrolling,
            bitmap: "Graphics/Battlebacks/Components/cloud#{i + 1}",
            speed: [0.5, 0.5, 0.25][i].lerp,
            direction: [1, -1, 1][i],
            ey: [98, 91, 30][i],
            visible: !PBDayNight.isNight? || !@room.outdoor?,
            anchor: :bottom_left
          )

          @room.set_color(@sprites.hash.box, @sprites["cloud_#{i}".to_sym])
        end
      end
      #-------------------------------------------------------------------------
      #  render sun sprite
      #-------------------------------------------------------------------------
      def draw_sun
        return unless !PBDayNight.isNight? || !@room.outdoor?

        @sprites.add(
          :sun,
          bitmap: 'Graphics/Battlebacks/Components/sun',
          anchor: :bottom_center,
          ex: 208,
          ey: @sprites.hash.box.ey - 3
        )
        @sprites.hash.sun.oy *= 4

        minutes = Time.now.hour * 60 + Time.now.min
        oy =
          if PBDayNight.isEvening?
            92 - 68 * (minutes - 17 * 60.0) / (3 * 60.0)
          elsif PBDayNight.isMorning?
            24 + 68 * (minutes - 5 * 60.0) / (5 * 60.0)
          else
            @sprites.hash.sun.bitmap.height * 4
          end

        @sprites.hash.sun.src_rect.height = [23, oy].min
        @sprites.hash.sun.oy = [23, oy].min
      end
      #-------------------------------------------------------------------------
      #  render stars for nightsky
      #-------------------------------------------------------------------------
      def draw_stars
        return if !PBDayNight.isNight? || !@room.outdoor?

        24.times do |i|
          @sprites.add(
            "star_#{i}".to_sym,
            bitmap: 'Graphics/Battlebacks/Components/star',
            anchor: :middle,
            ex: rand(@sprites.hash.box.bitmap.width),
            ey: rand(@sprites.hash.box.bitmap.height - 24),
            speed: rand(1...5),
            param: (0.6 + rand(41) / 100.0),
            opacity: 125,
            end_x: rand(185...256),
            toggle: 2
          )
        end
      end
      #-------------------------------------------------------------------------
      #  update star particles
      #-------------------------------------------------------------------------
      def update_sky_tone
        # apply rain conditions to skybox
        if rain
          @tone_color -= 2.lerp if @tone_color > -16
          @tone_gray  += 16.lerp if @tone_gray < 128
          return
        end

        @tone_color += 2.lerp if @tone_color < 0
        @tone_gray  -= 16.lerp if @tone_gray > 0
      end
      #-------------------------------------------------------------------------
      #  update star particles
      #-------------------------------------------------------------------------
      def update_stars
        return if !PBDayNight.isNight? || !@room.outdoor?

        24.times do |i|
          key = "star_#{i}".to_sym
          next unless @sprites[key]

          @sprites[key].opacity += (@sprites[key].toggle * @sprites[key].speed).lerp
          @sprites[key].toggle *= -1 if @sprites[key].opacity <= 125 || @sprites[key].opacity >= @sprites[key].end_x
        end
      end
      #-------------------------------------------------------------------------
    end
  end
end
