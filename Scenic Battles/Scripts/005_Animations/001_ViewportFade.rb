#===============================================================================
#  Shows the battle scene fading in while elements slide around into place
#===============================================================================
class Battle::Scene::Animation::ViewportFade < Battle::Scene::Animation
  DURATION = 10

  def initialize(sprites, viewport, battle)
    @battle = battle
    super(sprites, viewport)
  end

  def createProcesses
    # Fading blackness over whole screen
    blackScreen = addNewSprite(0, 0, 'Graphics/Battle animations/black_screen')
    blackScreen.setZ(0, 999)
    blackScreen.moveOpacity(0, DURATION / 2, 0)

    # Fading blackness over command bar
    blackBar = addNewSprite(@sprites['cmdBar_bg'].x, @viewport.height, 'Graphics/Battle animations/black_bar')
    blackBar.setZ(0, 998)
    blackBar.moveXY(0, DURATION, @sprites['cmdBar_bg'].x, @sprites['cmdBar_bg'].y)
  end
end
