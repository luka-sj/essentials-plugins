#===============================================================================
#  Scenic Battles: definition for environments, terrains, scenes and components
#===============================================================================
module BattleScenes
  #-----------------------------------------------------------------------------
  #  configuration of base environment types
  #-----------------------------------------------------------------------------
  module Environments
    OUTDOOR    = { sky: true, outdoor: true }
    INDOOR     = { outdoor: false }
    WATER      = { outdoor: true, water: true }
    UNDERWATER = { outdoor: false, underwater: true }
    FLYING     = { outdoor: true, sky: true, no_shadow: true }
  end
  #-----------------------------------------------------------------------------
  #  configuration of additional terrains
  #-----------------------------------------------------------------------------
  module Terrains
    PUDDLE   = { base: 'Puddle' }
    DIRT     = { base: 'Dirt' }
    CONCRETE = { base: 'Concrete' }
    WATER    = { base: 'Water', water: true }

    LAVA = {
      'terrain:lava' => {
        bitmap: 'base001', type: :scrolling, speed: 0.5, direction: -1,
        oy: 0, y: 122, z: 1, flat: true
      }
    }

    DIMENSION = {
      'terrain:dimension' => {
        bitmap: 'base001a', type: :scrolling, speed: 0.5, direction: -1,
        oy: 0, y: 122, z: 1, flat: true
      }
    }
  end
  #-----------------------------------------------------------------------------
  #  configuration of tree constellations
  #-----------------------------------------------------------------------------
  module Trees
    DEFAULT = {
      trees: {
        elements: 9,
        x: [150, 271, 78, 288, 176, 42, 118, 348, 321],
        y: [108, 117, 118, 126, 126, 128, 136, 136, 145],
        zoom: [0.44, 0.44, 0.59, 0.59, 0.59, 0.64, 0.85, 0.7, 1],
        mirror: [false, false, true, true, true, false, false, true, false]
      }
    }

    PINE = {
      trees: {
        bitmap: 'treePine', colorize: false, elements: 8,
        x: [92, 248, 300, 40, 138, 216, 274, 318],
        y: [132, 132, 144, 118, 112, 118, 110, 110],
        zoom: [1, 1, 1.1, 0.9, 0.8, 0.85, 0.75, 0.75],
        z: [2, 2, 2, 1, 1, 1, 1, 1]
      }
    }

    SKY = {
      trees: {
        bitmap: 'treeCluster', colorize: false, elements: 12,
        x: [26, 6, 44, 4, 136, 104, 372, 342, 236, 180, 214, 282],
        y: [184, 210, 216, 258, 188, 278, 212, 284, 234, 238, 258, 170],
        mirror: [false, false, true, true, false, false, true, false, false, false, false, false],
        zoom: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0.7],
        z: [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
      }
    }

    SNOW = {
      trees: {
        bitmap: 'treeB', colorize: :slight, elements: 9,
        x: [150, 271, 78, 288, 176, 42, 118, 348, 321],
        y: [108, 117, 118, 126, 126, 128, 136, 136, 145],
        zoom: [0.44, 0.44, 0.59, 0.59, 0.59, 0.64, 0.85, 0.7, 1],
        mirror: [false, false, true, true, true, false, false, true, false]
      }
    }

    SPREAD = {
      trees: {
        elements: 9,
        x: [150, 271, 78, 288, 176, 42, 118, 348, 321],
        y: [108, 117, 118, 122, 122, 127, 127, 128, 132],
        zoom: [0.44, 0.44, 0.59, 0.59, 0.59, 0.64, 0.85, 0.7, 1],
        mirror: [false, false, true, true, true, false, false, true, false]
      }
    }

    MOUNTAIN = {
      trees: {
        bitmap: 'treeC', colorize: :slight, elements: 8,
        x: [271, 78, 288, 176, 42, 118, 348, 321],
        y: [117, 118, 122, 122, 127, 127, 128, 132],
        zoom: [0.44, 0.59, 0.59, 0.59, 0.64, 0.85, 0.7, 1],
        mirror: [false, true, true, true, false, false, true, false]
      }
    }
  end
  #-----------------------------------------------------------------------------
  #  configuration of grass constellations
  #-----------------------------------------------------------------------------
  module Grass
    TALL = {
      grass: {
        elements: 7,
        x: [124, 274, 204, 62, 248, 275, 182],
        y: [160, 140, 140, 185, 246, 174, 170],
        z: [2, 1, 2, 17, 27, 17, 17],
        zoom: [0.7, 0.35, 0.5, 1, 1.5, 0.7, 1],
        mirror: [false, true, false, true, false, true, false]
      }
    }

    SEA = {
      grass: {
        elements: 5, bitmap: 'seaWeed',
        x: [124, 274, 62, 248, 275],
        y: [160, 140, 185, 246, 174],
        z: [2, 1, 17, 27, 17],
        zoom: [0.5, 0.15, 0.6, 1, 0.5],
        mirror: [false, true, true, false, true]
      }
    }
  end
  #-----------------------------------------------------------------------------
  #  configuration of mountain backdrops
  #-----------------------------------------------------------------------------
  module Mountains
    A = { 'mountain' => { bitmap: 'mountain',  x: 192, y: 107 } }
    B = { 'mountain' => { bitmap: 'mountainB', x: 192, y: 107 } }
    C = { 'mountain' => { bitmap: 'mountainC', x: 192, y: 107 } }
  end
  #-----------------------------------------------------------------------------
  #  configuration of active fogs
  #-----------------------------------------------------------------------------
  module Fogs
    TOP = {
      'fog:top' => {
        bitmap: 'fog', type: :scrolling, speed: 0.5, direction: 1,
        oy: 0, z: 4, flat: true
      }
    }

    BASE = {
      'fog:base' => {
        bitmap: 'base001c', type: :scrolling, speed: 0.5,
        oy: 0, y: 122, z: 3, flat: true
      }
    }

    DARK = {
      'fog:dark' => {
        bitmap: 'darkFog', type: :scrolling, speed: 0.5,
        oy: 0, y: 0, z: 5, flat: true
      }
    }
  end
  #-----------------------------------------------------------------------------
  #  configuration of scene decorations
  #-----------------------------------------------------------------------------
  module Decors
    CAVE = {
      'decor:cave:1' => {
        bitmap: 'decor006', type: :scrolling, speed: 2, direction: -1,
        oy: 0, z: 3, flat: true, opacity: 155
      }, 'decor:cave:2' => {
        bitmap: 'decor009', type: :scrolling, speed: 1, direction: 1,
        oy: 0, z: 3, flat: true, opacity: 96
      }
    }

    STAGE = {
      'decor:stage:1' => {
        bitmap: 'decor001', type: :scrolling, speed: 1, oy: 0, z: 1, flat: true
      }, 'decor:stage:2' => {
        bitmap: 'decor002', type: :scrolling, speed: 1, direction: -1, oy: 0, z: 1, flat: true
      }
    }

    DISCO = {
      'disco:bg' => {
        bitmap: 'discoBg', ox: 0, flat: true, type: :rainbow, speed: 8
      }
    }

    INDOOR = {
      'decor:indoor:1' => {
        bitmap: 'decor007', oy: 0, z: 1, flat: true, type: :scrolling, speed: 0.5
      }, 'decor:indoor:2' => {
        bitmap: 'decor008', oy: 0, z: 1, flat: true, type: :scrolling, direction: -1
      }
    }

    NET = {
      'decor:net' => {
        bitmap: 'decor003d', type: :scrolling, vertical: true, speed: 1,
        oy: 180, y: 90, flat: true
      }
    }

    CHAMPION = {
      'decor:champion:3' => {
        bitmap: 'decor003', type: :scrolling, vertical: true, speed: 1,
        oy: 180, y: 90, z: 1, flat: true
      }, 'decor:champion:4' => {
        bitmap: 'decor004', oy: 100, y: 98, z: 2, flat: false
      }
    }

    STREAKS = {
      'decor:streaks:5' => {
        bitmap: 'decor005', type: :scrolling, speed: 16,
        oy: 0, y: 4, z: 4, flat: true
      }, 'decor:streaks:6' => {
        bitmap: 'decor006', type: :scrolling, speed: 16, direction: -1,
        oy: 0, z: 4, flat: true
      }
    }

    PILLARS = {
      'decor:pillar:1' => { bitmap: 'pillars001', y: 128, x: 144, z: 3 },
      'decor:pillar:2' => { bitmap: 'pillars002', y: 192, x: 144, z: 19 }
    }

    DARKNESS = {
      'decor:dark:1' => {
        bitmap: 'dark001', oy: 70, ox: 70, y: 128, x: 248, z: 2, effect: 'rotate', zoom: 0.75
      }, 'decor:dark:2' => {
        bitmap: 'dark002', oy: 120, ox: 120, y: 128, x: 242, z: 3, direction: -1, effect: 'rotate', zoom: 0.75
      }, 'decor:dark:3' => {
        bitmap: 'dark003', oy: 110, ox: 110, y: 128, x: 234, z: 4, effect: 'rotate'
      }
    }

    DIMENSION = {
      'decor:dimension:3' => {
        bitmap: 'decor003a', type: :scrolling, vertical: true, speed: 1, oy: 180, y: 90, flat: true
      }, 'decor:shade' => {
        bitmap: 'shade', oy: 100, y: 98, flat: false
      }
    }
  end
  #-----------------------------------------------------------------------------
  #  configuration of scene lighting
  #-----------------------------------------------------------------------------
  module Lights
    ROOM   = { 'Lights::A'     => true }
    DISCO  = { 'Lights::B'     => true }
    FOREST = { 'Lights::C'     => true }
    STAGE  = { 'Lights::Stage' => true }
  end
  #-----------------------------------------------------------------------------
  #  configuration of bubble effects
  #-----------------------------------------------------------------------------
  module Bubbles
    CAVE  = { bubbles: 'bubbleDark' }
    WATER = { bubbles: 'bubble' }
    MAGMA = { bubbles: 'bubbleRed' }
  end
  #-----------------------------------------------------------------------------
  #  configuration of crowd animations
  #-----------------------------------------------------------------------------
  module Crowds
    A = {
      'crowd:a' => {
        bitmap: 'crowd',
        oy: 32, y: 102, z: 2, flat: false, type: :sheet,
        vertical: true, speed: 12, frames: 2
      }
    }

    B = {
      'crowd:b' => {
        bitmap: 'crowdB',
        oy: 32, y: 112, z: 2, flat: false, type: :sheet,
        vertical: true, speed: 16, frames: 2
      }
    }
  end
  #-----------------------------------------------------------------------------
  #  configuration of scene shading
  #-----------------------------------------------------------------------------
  module Shades
    FOREST = {
      'shade:forest' => {
        bitmap: 'forestShade', z: 1, flat: true,
        oy: 0, y: 94, type: :sheet, frames: 2, speed: 16
      }
    }
  end
  #=============================================================================
  #  configuration of actual battle scenes
  #=============================================================================
  module Scenes
    #---------------------------------------------------------------------------
    #  outdoor scenes
    #---------------------------------------------------------------------------
    FIELD = { backdrop: 'Field' }.merge_many(
      Environments::OUTDOOR, Trees::DEFAULT
    )

    WATER = { backdrop: 'Water' }.merge_many(
      Environments::WATER
    )

    SNOW = { backdrop: 'Snow' }.merge_many(
      Environments::OUTDOOR, Mountains::B, Trees::SNOW
    )

    SKY = { backdrop: 'Sky' }.merge_many(
      Environments::FLYING, Trees::SKY, Fogs::BASE
    )

    MOUNTAIN = { backdrop: 'Mountain' }.merge_many(
      Environments::OUTDOOR, Mountains::C, Trees::MOUNTAIN
    )

    MOUNTAIN_LAKE = { backdrop: 'Field' }.merge_many(
      Environments::OUTDOOR, Mountains::A, Terrains::WATER, Trees::SPREAD
    )
    #---------------------------------------------------------------------------
    #  cave scenes
    #---------------------------------------------------------------------------
    CAVE = { backdrop: 'Cave' }.merge_many(
      Environments::INDOOR, Decors::CAVE, Fogs::TOP
    )

    DARKCAVE = { backdrop: 'CaveDark' }.merge_many(
      Environments::INDOOR, Fogs::TOP, Bubbles::CAVE
    )

    MAGMA = { backdrop: 'Cave' }.merge_many(
      Environments::INDOOR, Terrains::LAVA, Decors::CAVE, Fogs::TOP, Bubbles::MAGMA
    )
    #---------------------------------------------------------------------------
    #  indoor scenes
    #---------------------------------------------------------------------------
    INDOOR = { backdrop: 'IndoorA' }.merge_many(
      Environments::INDOOR, Decors::INDOOR, Lights::ROOM
    )

    STAGE = { backdrop: 'IndoorB' }.merge_many(
      Environments::INDOOR, Decors::STAGE, Lights::STAGE, Lights::ROOM
    )

    DISCO = { backdrop: 'DanceFloor' }.merge_many(
      Environments::INDOOR, Decors::DISCO, Lights::DISCO, Crowds::A
    )

    NET = { backdrop: 'Net' }.merge_many(
      Environments::INDOOR, Decors::NET, Crowds::B
    )

    CHAMPION = { backdrop: 'Champion' }.merge_many(
      Environments::INDOOR, Decors::CHAMPION, Decors::STREAKS, Terrains::LAVA, Decors::PILLARS, Lights::ROOM
    )

    FOREST = { backdrop: 'Forest' }.merge_many(
      Environments::INDOOR, Shades::FOREST, Trees::PINE, Lights::FOREST
    )

    UNDERWATER = { backdrop: 'Underwater' }.merge_many(
      Environments::UNDERWATER, Shades::FOREST, Grass::SEA, Lights::FOREST, Bubbles::WATER
    )

    DARKNESS = { backdrop: 'Darkness', vacuum: true }.merge_many(
      Environments::INDOOR, Decors::DARKNESS, Fogs::DARK
    )

    DIMENSION = { backdrop: 'Sapphire', vacuum: 'dark006' }.merge_many(
      Environments::INDOOR, Terrains::DIMENSION, Decors::DIMENSION, Decors::STREAKS
    )
    #---------------------------------------------------------------------------
  end
  #=============================================================================
end
