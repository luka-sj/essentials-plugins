#===============================================================================
#  Scene class override for extensions
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  #  Battle scene room
  #-----------------------------------------------------------------------------
  def room
    @sprites['battle_bg']
  end
  #-----------------------------------------------------------------------------
  #  Creates backdrop components for scene
  #-----------------------------------------------------------------------------
  def pbCreateBackdropSprites
    # battle environment
    @sprites['battle_bg'] = SCBA::Room.new(@viewport, @battle, self)

    # message box
    file = @battle.backdrop
    if time_extension
      trial = sprintf('%s_%s', file, time_extension)
      file  = trial if pbResolveBitmap(sprintf('Graphics/Battlebacks/%s_message', trial))
    end

    # fallback to indoor display
    file = 'indoor1' unless pbResolveBitmap("Graphics/BattleBacks/#{file}_message")

    cmd_bar_bg = pbAddSprite('cmdBar_bg', 0, Graphics.height - 96, "Graphics/BattleBacks/#{file}_message", @viewport)
    cmd_bar_bg.z = 180
  end
  #-----------------------------------------------------------------------------
  #  Interprets time based file extension
  #-----------------------------------------------------------------------------
  def time_extension
    @time_extension ||=
      case @battle.time
      when 1 then :eve
      when 2 then :night
      end
  end
  #-----------------------------------------------------------------------------
  #  Inject custom animations to battle start
  #-----------------------------------------------------------------------------
  alias pbBattleIntroAnimation_scba pbBattleIntroAnimation
  def pbBattleIntroAnimation
    # Fade in viewport
    runAnimation(:viewport_fade)

    pbBattleIntroAnimation_scba
  end
  #-----------------------------------------------------------------------------
  #  Helper to easily run animations
  #-----------------------------------------------------------------------------
  def runAnimation(animation)
    anim = "Battle::Scene::Animation::#{animation.to_s.camelize}".constantize.new(@sprites, @viewport, @battle)

    loop do
      anim.update
      pbUpdate
      break if anim.animDone?
    end

    anim.dispose
  end
  #-----------------------------------------------------------------------------
end
