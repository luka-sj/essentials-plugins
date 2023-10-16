#===============================================================================
#  Battle scene room constructor
#===============================================================================
module SCBA
  module Rooms
    class Default
      include SCBA::Common::Vector

      attr_reader :sprites, :focused, :sunny, :strong_wind, :wind, :dynamax, :frame
      #-------------------------------------------------------------------------
      #  class constructor
      #-------------------------------------------------------------------------
      def initialize(viewport, battle_scene, data)
        @viewport     = viewport
        @battle_scene = battle_scene
        @sprites      = LUTS::SpriteHash.new(@viewport)
        @focused      = true
        @sunny        = false
        @strong_wind  = false
        @dynamax      = false
        @frame        = 0
        @vector       = Vector.new(x: Graphics.width / 2, y: Graphics.height / 2, zoom_x: 1.7, zoom_y: 1.5)
        @wind         = {
          speed: 90, wait: 0, toggle: 0.5
        }

        render_void
        refresh(data)
      end
      #-------------------------------------------------------------------------
      #  update all sprites in collection and position them relative to the
      #  room backdrop
      #-------------------------------------------------------------------------
      def update
        update_room_position

        @sprites.each do |_key, sprite|
          sprite.update
          sprite.position if sprite.respond_to?(:position)
        end

        calculate_wind_speeds

        @frame += 1
        @frame = 0 if @frame > 512 * Graphics.average_frame_rate / 60.0
      end
      #-------------------------------------------------------------------------
      #  check if room is an outdoor one
      #-------------------------------------------------------------------------
      def outdoor?
        @data[:outdoor].eql?(true) && Settings::TIME_SHADING
      end
      #-------------------------------------------------------------------------
      #  defocus current room (move to background)
      #-------------------------------------------------------------------------
      def defocus
        return if @sprites[:backdrop].z < 0

        @sprites.each do |_key, sprite|
          sprite.z -= 100
        end
        @focused = false
      end
      #-------------------------------------------------------------------------
      #  focus current room (move to foreground)
      #-------------------------------------------------------------------------
      def focus
        return if @sprites[:backdrop].z >= 0

        @sprites.each do |_key, sprite|
          sprite.z += 100
        end
        @focused = true
      end
      #-------------------------------------------------------------------------
      #  set color based on target sprite
      #-------------------------------------------------------------------------
      def set_color(target, sprite, color = true)
        return unless target.bitmap && sprite.ex && sprite.ey

        c = target.bitmap.get_pixel(sprite.ex, sprite.ey)
        a = color.eql?(:slight) ? 128 : 255
        sprite.colorize(c, amount: a)
      end
      #-------------------------------------------------------------------------
      #  room disposal methods
      #-------------------------------------------------------------------------
      def dispose
        @sprites.dispose
      end

      def disposed?
        @sprites.disposed?
      end
      #-------------------------------------------------------------------------
      #  compatibility layers for scene transitions
      #-------------------------------------------------------------------------
      def color
        @viewport.color
      end

      def color=(val)
        @viewport.color = val
      end

      def visible
        @sprites.hash&.backdrop&.visible
      end

      def visible=(val)
        @sprites.each do |_key, sprite|
          sprite.visible = val
        end
      end

      private
      #-------------------------------------------------------------------------
      #  render empty (background) void
      #-------------------------------------------------------------------------
      def render_void
        @sprites.add(:void, full_rect: Color.black, z: -10)
      end
      #-------------------------------------------------------------------------
      #  refresh room data and re-render
      #-------------------------------------------------------------------------
      def refresh(data_hash)
        @sprites.dispose(except: :void)
        @data = data_hash.clone
        render_backdrop

        # iterate through all data keys
        @data.except(*skip_components).each do |key, data|
          next if key.eql?(:backdrop)

          # load string keys as regular sprite objects
          if key.is_a?(String) && data.is_a?(Hash)
            render_user_defined_component(key, data)
            next
          end
          # if scripted component is defined, instanciate class object
          component = "SCBA::Components::#{key.is_a?(String) ? key : key.to_s.camelize}"

          if SCBA.const_defined?(component)
            render_script_component(key, data, component)
          else
            LUTS::ErrorMessages::ComponentError.new(component).raise
          end
        end

        # fill void based on backdrop colors
        fill_void_colors if @sprites[:backdrop]
        # applies shading to all sprites
        apply_daytime_shading
      end
      #-------------------------------------------------------------------------
      #  render hardcoded backdrop component
      #-------------------------------------------------------------------------
      def render_backdrop
        @sprites.add(:backdrop, object: SCBA::Components::Backdrop.new(@viewport, @data[:backdrop], self))
        @sprites.hash.backdrop.anchor(:middle)
      end
      #-------------------------------------------------------------------------
      #  render user defined components
      #-------------------------------------------------------------------------
      def render_user_defined_component(key, data)
        @sprites.add(key.to_s.downcase.gsub(':', '_').to_sym, object: SCBA::Components::Sprite.new(@viewport, data, self))
      end
      #-------------------------------------------------------------------------
      #  render predefined script components
      #-------------------------------------------------------------------------
      def render_script_component(key, data, component)
        @sprites.add(key.to_s.downcase.gsub(':', '_').to_sym, object: component.constantize.new(@viewport, data, self))
      end
      #-------------------------------------------------------------------------
      #  fill void with top-most and bottom-most backdrop colors
      #-------------------------------------------------------------------------
      def fill_void_colors
        return unless @sprites[:backdrop].bitmap

        bitmap       = @sprites[:backdrop].bitmap
        color_top    = bitmap.get_pixel(0, 0)
        color_bottom = bitmap.get_pixel(0, bitmap.height - 1)

        @sprites.hash.void.bitmap.fill_rect(0, 0, @viewport.width, @viewport.height / 2, color_top)
        @sprites.hash.void.bitmap.fill_rect(0, @viewport.height / 2, @viewport.width, @viewport.height / 2, color_bottom)
      end
      #-------------------------------------------------------------------------
      #  add daytime shading across all sprites
      def apply_daytime_shading
        return unless outdoor?

        @sprites.keys.reject { |key| [:sky].include?(key) || key.to_s.include?('lights') }.each do |key|
          next if @data[key].is_a?(Hash) && @data[key]&.value(:shading).eql?(false)

          (@sprites[key].respond_to?(:sprites) ? @sprites[key].sprites : { sprite: @sprites[key] }).each do |_key, sprite|
            sprite.tone =
              if PBDayNight.isNight? && !@sunny
                Tone.new(-120, -100, -60)
              elsif (PBDayNight.isEvening? || PBDayNight.isMorning?) && !@sunny
                Tone.new(-16, -52, -56)
              else
                Tone.new(0, 0, 0)
              end
          end
        end
      end
      #-------------------------------------------------------------------------
      #  update room wind state
      #-------------------------------------------------------------------------
      def calculate_wind_speeds
        # adjusts for wind affected elements
        if @strongwind
          @wind[:speed] -= (@wind[:toggle] * 2).lerp
          @wind[:toggle] *= -1 if @wind[:speed] < 65 || (@wind[:speed] >= 70 && @wind[:toggle] < 0)
          return
        end

        # adds to wind wait times and calculates if 5 seconds have passed
        @wind[:wait] += 1.lerp
        return unless @wind[:wait] > Graphics.average_frame_rate * 5.0

        @wind[:speed] -= (@wind[:toggle] * (2 + (@wind[:speed] >= 88 && @wind[:speed] <= 92 ? 2 : 0))).lerp
        @wind[:toggle] *= -1 if @wind[:speed] <= 80 || @wind[:speed] >= 100
        @wind[:wait] = 0 if @wind[:wait] > Graphics.average_frame_rate * 5.0 + 33
      end
      #-------------------------------------------------------------------------
      #  skip components to initialize
      #-------------------------------------------------------------------------
      def skip_components
        [:outdoor, :underwater]
      end

      def backdrop
        @sprites.hash.backdrop
      end
      #-------------------------------------------------------------------------
    end
  end
end
