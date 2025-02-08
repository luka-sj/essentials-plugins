#===============================================================================
#  Shows battle scene intro transition
#===============================================================================
class Battle::Scene::Animation::Intro < Battle::Scene::Animation
  DURATION  = 40
  INCREMENT = 40 / 6

  def initialize(sprites, viewport, battle)
    @battle = battle
    super(sprites, viewport)
  end

  def createProcesses
    # Player sprite, partner trainer sprite
    @battle.player.each_with_index do |_p, i|
      makeSlideSprite("player_#{i + 1}", 1, PictureOrigin::BOTTOM)
    end

    # Opposing trainer sprite(s) or wild Pokémon sprite(s)
    if @battle.trainerBattle?
      @battle.opponent.each_with_index do |_p, i|
        makeSlideSprite("trainer_#{i + 1}", -1, PictureOrigin::BOTTOM)
      end
    else # Wild battle
      @battle.pbParty(1).each_with_index do |_pkmn, i|
        makeSlideSprite("pokemon_#{(2 * i) + 1}", -1, PictureOrigin::BOTTOM)
      end
    end

    # Shadows
    @battle.battlers.length.times do |i|
      makeSlideSprite("shadow_#{i}", i.even? ? 1 : -1, PictureOrigin::CENTER)
      @sprites["shadow_#{i}"].opacity = 0 unless @battle.scene.room.shadows?
    end

    # Fading blackness over whole screen
    overlay = addSprite(overlay_sprite)
    overlay.moveOpacity(INCREMENT * 4, INCREMENT, 0)
    overlay.moveColor(INCREMENT, INCREMENT * 2, Color.white)

    # Fading blackness over command bar
    blackBar = addNewSprite(@sprites['cmdBar_bg'].x, @sprites['cmdBar_bg'].y, 'Graphics/Battle animations/black_bar')
    blackBar.setZ(0, 998)
    blackBar.moveOpacity(INCREMENT * 5, INCREMENT, 0)

    # Background
    vector.set(x: vector.x + 128, duration: DURATION * 3)
  end

  def makeSlideSprite(name, delta, origin = nil)
    # If deltaMult is positive, the sprite starts off to the right and moves
    # left (for sprites on the player's side and the background).
    return unless @sprites[name]

    s = addSprite(@sprites[name], origin)
    s.setDelta(0, (Graphics.width * delta).floor, 0)
    s.moveDelta(0, DURATION, (-Graphics.width * delta).floor, 0)
  end

  def vector
    @vector ||= @battle.scene.room.vector
  end

  def overlay_sprite
    @overlay_sprite ||= @battle.scene.room.sprites.hash.overlay
  end
end
