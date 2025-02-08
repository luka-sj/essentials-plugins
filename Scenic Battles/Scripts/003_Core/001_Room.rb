#===============================================================================
#  Battle scene room constructor
#===============================================================================
module SCBA
  class Room
    include SCBA::Common::Vector

    # Vector configuration
    VECTOR = {
      x: 256 - 96,
      y: 142,
      zoom_x: 1.7,
      zoom_y: 1.5
    }.freeze

    attr_reader :sprites, :focused, :weather, :strong_wind, :wind, :dynamax, :frame
    #---------------------------------------------------------------------------
    #  Class constructor
    #---------------------------------------------------------------------------
    def initialize(viewport, battle, scene)
      @viewport     = viewport
      @battle       = battle
      @scene        = scene
      @sprites      = SpriteHash.new(@viewport)
      @focused      = true
      @sunny        = false
      @strong_wind  = false
      @dynamax      = false
      @frame        = 0
      @weather      = nil
      @vector       = Vector.new(**VECTOR)
      @wind         = {
        speed: 90, wait: 0, toggle: 0.5, c: 0
      }

      render_overlay
      render_void
      refresh(scene_data)
    end
    #---------------------------------------------------------------------------
    #  Essentials compatibility functions
    #---------------------------------------------------------------------------
    def src_rect
      @src_rect ||= Rect.new(0, 0, @viewport.width, @viewport.height)
    end

    def z
      0
    end

    def z=(val); end
    def tone; end
    def tone=(val); end
    #---------------------------------------------------------------------------
    #  Update all sprites in collection and position them relative to the
    #  room backdrop
    #---------------------------------------------------------------------------
    def update
      update_room_position

      @sprites.each do |_key, sprite|
        sprite.update
        sprite.position if sprite.respond_to?(:position)
      end

      calculate_wind_speeds

      toggle_weather(battle_weather) unless @weather.eql?(battle_weather)

      @frame += 1
      @frame = 0 if @frame > 512 * Graphics.average_frame_rate / 60.0
    end
    #---------------------------------------------------------------------------
    #  Check if room is an outdoor one
    #---------------------------------------------------------------------------
    def outdoor?
      @data[:outdoor].eql?(true) && Settings::TIME_SHADING
    end
    #---------------------------------------------------------------------------
    #  Defocus current room (move to background)
    #---------------------------------------------------------------------------
    def defocus
      return if @sprites[:backdrop].z < 0

      @sprites.each do |_key, sprite|
        sprite.z -= 100
      end
      @focused = false
    end
    #---------------------------------------------------------------------------
    #  Focus current room (move to foreground)
    #---------------------------------------------------------------------------
    def focus
      return if @sprites[:backdrop].z >= 0

      @sprites.each do |_key, sprite|
        sprite.z += 100
      end
      @focused = true
    end
    #---------------------------------------------------------------------------
    #  Toggle weather
    #---------------------------------------------------------------------------
    def toggle_weather(type)
      klass     = type.to_s.camelize
      component = "SCBA::Components::Weather::#{klass}"

      # set weather if previous one already present
      if @weather.eql?(type) && @sprites.key?(type)
        @sprites.dispose(only: type)
        @weather = nil
        return
      end

      # if component exists
      unless SCBA.const_defined?(component)
        LUTS::ErrorMessages::ComponentError.new(component).raise
        return
      end

      # set current weather
      @sprites.dispose(only: @weather) unless @weather.nil?
      @sprites.add(type, object: component.constantize.new(@viewport, {}, self))
      @weather = type
    end

    def clear_weather
      @sprites.dispose(only: @weather) unless @weather.nil?
      @weather = nil
    end
    #---------------------------------------------------------------------------
    #  Set color based on target sprite
    #---------------------------------------------------------------------------
    def set_color(target, sprite, color = true)
      return unless target.bitmap && sprite.ex && sprite.ey

      c = target.bitmap.get_pixel(sprite.ex, sprite.ey)
      a = color.eql?(:slight) ? 128 : 255
      sprite.colorize(c, amount: a)
    end
    #---------------------------------------------------------------------------
    #  Room disposal methods
    #---------------------------------------------------------------------------
    def dispose
      @sprites.dispose
    end

    def disposed?
      @sprites.disposed?
    end
    #---------------------------------------------------------------------------
    #  Compatibility layers for scene transitions
    #---------------------------------------------------------------------------
    def focused?
      @focused
    end

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
    #---------------------------------------------------------------------------
    #  Data components
    #---------------------------------------------------------------------------
    def backdrop_name
      @data[:backdrop]
    end

    def shadows?
      !@data[:no_shadow]
    end

    private
    #---------------------------------------------------------------------------
    #  Render empty (background) void
    #---------------------------------------------------------------------------
    def render_void
      @sprites.add(:void, full_rect: Color.black, z: -10)
    end

    def render_overlay
      @sprites.add(:overlay, full_rect: Color.black, z: 997)
    end
    #---------------------------------------------------------------------------
    #  Refresh room data and re-render
    #---------------------------------------------------------------------------
    def refresh(data_hash)
      @sprites.dispose(except: [:void, :overlay])
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
      fill_overlay_colors if @sprites[:backdrop]
      # applies shading to all sprites
      apply_daytime_shading
    end
    #---------------------------------------------------------------------------
    #  Render hardcoded backdrop component
    #---------------------------------------------------------------------------
    def render_backdrop
      @sprites.add(:backdrop, object: SCBA::Components::Backdrop.new(@viewport, backdrop_name, self))
      @sprites.hash.backdrop.anchor(:middle)
    end
    #---------------------------------------------------------------------------
    #  Render user defined components
    #---------------------------------------------------------------------------
    def render_user_defined_component(key, data)
      @sprites.add(key.to_s.downcase.gsub(':', '_').to_sym, object: SCBA::Components::Sprite.new(@viewport, data, self))
    end
    #---------------------------------------------------------------------------
    #  Render predefined script components
    #---------------------------------------------------------------------------
    def render_script_component(key, data, component)
      @sprites.add(key.to_s.downcase.gsub(':', '_').to_sym, object: component.constantize.new(@viewport, data, self))
    end
    #---------------------------------------------------------------------------
    #  Fill void with top-most and bottom-most backdrop colors
    #---------------------------------------------------------------------------
    def fill_void_colors
      return unless backdrop.bitmap

      color_top    = backdrop.bitmap.get_pixel(1, 1)
      color_bottom = backdrop.bitmap.get_pixel(1, backdrop.bitmap.height - 1)

      @sprites.hash.void.bitmap.fill_rect(0, 0, @viewport.width, @viewport.height / 2, color_top)
      @sprites.hash.void.bitmap.fill_rect(0, @viewport.height / 2, @viewport.width, @viewport.height / 2, color_bottom)
    end

    def fill_overlay_colors
      return unless backdrop.bitmap

      color_top = backdrop.bitmap.get_pixel(1, 1)

      @sprites.hash.overlay.bitmap.fill_rect(0, 0, @viewport.width, @viewport.height, color_top)
    end
    #---------------------------------------------------------------------------
    #  Add daytime shading across all sprites
    #---------------------------------------------------------------------------
    def apply_daytime_shading
      return unless outdoor?

      @sprites.keys.reject { |key| [:sky].include?(key) || key.to_s.include?('lights') }.each do |key|
        next if @data[key].is_a?(Hash) && @data.dig(key, :shading).eql?(false)

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
    #---------------------------------------------------------------------------
    #  Update room wind state
    #---------------------------------------------------------------------------
    def calculate_wind_speeds
      max_wait = @strong_wind ? 4.0 : 8.0

      # adds to wind wait times and calculates if 5 seconds have passed
      @wind[:wait] += 1.lerp
      return unless @wind[:wait] > Graphics.average_frame_rate * max_wait

      @wind[:speed] -= (@wind[:toggle] * 0.5).lerp

      # maximum offset for sway
      if @wind[:speed] <= 85
        @wind[:toggle] *= -1
        @wind[:speed] = 85
        @wind[:c] += 1
      end
      #
      # if @wind[:speed] >= 95
      #   @wind[:toggle] *= -1
      #   @wind[:speed] = 95
      #   @wind[:c] += 1
      # end

      return unless @wind[:c] >= 1 && @wind[:speed] >= 90

      # reset wind when animation is complete
      @wind[:toggle] = 1
      @wind[:speed] = 90
      @wind[:wait] = 0
      @wind[:c] = 0
    end
    #---------------------------------------------------------------------------
    #  Skip components to initialize
    #---------------------------------------------------------------------------
    def skip_components
      [:outdoor, :underwater]
    end

    def backdrop
      @sprites.hash.backdrop
    end
    #---------------------------------------------------------------------------
    #  Compile scene based on environment
    #---------------------------------------------------------------------------
    def scene_data
      @scene_data ||= queued_scene || metadata_scene || environment_scene || default_scene
    end

    def default_scene
      if $game_map.metadata&.outdoor_map
        BattleScenes::Scenes::FIELD
      elsif $PokemonEncounters.has_cave_encounters?
        BattleScenes::Scenes::CAVE
      else
        BattleScenes::Scenes::NONE
      end
    end

    def queued_scene
      return if $PokemonGlobal.nextBattleBack.nil?

      "BattleScenes::Scenes::#{parse_empty($PokemonGlobal.nextBattleBack).to_s.upcase}".safe_constantize
    end

    def environment_scene
      return if scene_name.nil?

      "BattleScenes::Scenes::#{parse_empty(scene_name).to_s.upcase}".safe_constantize
    end

    def metadata_scene
      return if $game_map.metadata.battle_background.nil?

      "BattleScenes::Scenes::#{parse_empty($game_map.metadata.battle_background).to_s.upcase}".safe_constantize
    end

    def scene_name
      @scene_name ||= GameData::Environment.try_get(@battle&.environment)&.id
    end

    def parse_empty(name)
      return name unless name.eql?(:None)

      if $game_map.metadata&.outdoor_map
        :Field
      elsif $PokemonEncounters.has_cave_encounters?
        :Cave
      else
        :None
      end
    end

    def battle_weather
      @battle.respond_to?(:field) ? @battle.field.weather : @battle.weather
    end
    #---------------------------------------------------------------------------
  end
end
