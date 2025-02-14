#==============================================================================
#  Screen Effects
#     by Luka S.J.
#     Small collection of code to apply weird screen effects to your
#     overworld map.
#==============================================================================
module ScreenEffects
  class << self
    attr_accessor :active_effect
    #--------------------------------------------------------------------------
    #  Inverts the screen (with animation if specified).
    #    Function acts as a toggle, if screen is already inverted,
    #    calling it again will revert the screen to normal.
    #--------------------------------------------------------------------------
    def invert(animate: true)
      return unless $scene.is_a?(Scene_Map)

      val = ScreenEffects.active_effect.eql?(:inversion) ? nil : :inversion
      if animate
        animate_inversion { ScreenEffects.active_effect = val }
      else
        ScreenEffects.active_effect = val
      end
    end
    #--------------------------------------------------------------------------
    #  Removes all current screen effects
    #--------------------------------------------------------------------------
    def restore
      return unless $scene.is_a?(Scene_Map)

      ScreenEffects.active_effect = nil
    end
    #--------------------------------------------------------------------------
    #  Applies defined screen effects to current Spriteset
    #--------------------------------------------------------------------------
    def apply(spriteset)
      return if spriteset.disposed?

      case active_effect
      when :inversion then apply_inversion(spriteset)
      else
        spriteset.bitmap = nil
      end
    end

    private
    #--------------------------------------------------------------------------
    #  Applies inversion effect to current Spriteset
    #--------------------------------------------------------------------------
    def apply_inversion(spriteset)
      spriteset.bitmap = Spriteset_Map.viewport.flatten
      spriteset.center!(snap: true)
      spriteset.angle = 180
    end
    #--------------------------------------------------------------------------
    #  Adds animation when inverting the screen
    #--------------------------------------------------------------------------
    def animate_inversion(&block)
      bmp = Spriteset_Map.viewport.flatten
      sprites = SpriteHash.new(Screens::Top.new)

      20.times do |i|
        a = ScreenEffects.active_effect.eql?(:inversion) ? 180 : 0
        s = sprites.add(i, bitmap: bmp, angle: ((i + 1) * 9) + a, opacity: 128)
        s.center!(snap: true)
        Graphics.animate(4)
      end

      block.call
      Graphics.animate(8) { sprites[19].animate(opacity: 255) }

      $scene.update
      sprites.dispose
    end
    #--------------------------------------------------------------------------
  end
end
#==============================================================================
#  Scene_Map overrides to add screen effects to Spriteset
#==============================================================================
class Scene_Map
  alias with_screen_effects_initialize initialize
  def initialize
    with_screen_effects_initialize
    @screen_effects = Sprites::Base.new(Viewport.new(Graphics.width, Graphics.height))
  end

  alias with_screen_effects_updateSpritesets updateSpritesets
  def updateSpritesets(refresh = false)
    with_screen_effects_updateSpritesets(refresh)
    ScreenEffects.apply(@screen_effects)
  end
end
#==============================================================================
SaveData.register(:screen_effect) do
  save_value     { ScreenEffects.active_effect }
  load_value     { |value| ScreenEffects.active_effect = value }
  new_game_value { nil }
end
