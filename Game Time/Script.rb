#===============================================================================
#  Game Time module
#    New components for an unreal-like time engine.
#    Bypasses the real-world `Time.now` components and
#    allows the game to keep track of its own in-game
#    time.
#===============================================================================
module GameTime
  #  Main class for the current time
  class Now
    #  Public attributes
    attr_accessor :hour
    attr_accessor :minute
    attr_accessor :second
    attr_accessor :day
    attr_accessor :month
    attr_accessor :year

    #  How many days in a month.
    #  Does not take leap years into consideration as year is constant
    #  and not taken into account.
    MONTH_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze
    #  Rate of progression, being 1 real life day = 7.5 in game days.
    #  Calculation based off the target frame rate of 60 FPS:
    #    - 60 in game seconds pass every frame (every second)
    #    - 60 in game days per 24 real life hours * 0.125 = 7.5
    RATE = 0.125
    #  Toggle to progress years.
    #  Since in-game time progresses faster than real life time
    #  years would fly by, making it a little silly
    PROGRESS_YEAR = false

    #  Class constructor
    #  Defines time and date when the in-game time starts
    #  Replace the numeric values with the corresponding `Time.now` values
    #    Default: 12:00:00, 1st June 2025
    def initialize
      @hour   = 12
      @minute = 0
      @second = 0
      @day    = 1
      @month  = 6
      @year   = 2025
      @lock   = false
    end

    #  Updates the current time progression cycle.
    #  Should be called each frame from the main scene.
    def progress
      return if locked?

      @second += RATE.lerp
      progress_minutes
      progress_hours
      progress_days
      progress_months
      progress_years
    end

    #  Locks in-game time progression
    def lock
      @lock = true
    end

    #  Unlocks in-game time progression
    def unlock
      @lock = false
    end

    #  Checks if time progression is currently locked
    def locked?
      @lock
    end

    #  Alias to keep compatible with `Time.now` standards
    def mon; @month;  end
    def min; @minute; end

    #  Converts current date into seconds
    def to_i
      year_seconds + month_seconds + day_seconds + seconds
    end

    #  Converts current hour into seconds
    def seconds
      (@hour * 60 * 60) + (@minute * 60) + (@second)
    end

    #  Get month name
    def month_name
      pbGetMonthName(@month)
    end

    #  Get abbreviated month name
    def month_name_short
      pbGetAbbrevMonthName(@month)
    end

    private

    #  Progresses each in-game minute
    def progress_minutes
      return unless @second >= 60

      @minute += 1
      @second = 0
    end

    #  Progresses each in-game hour
    def progress_hours
      return unless @minute >= 60

      @hour += 1
      @minute = 0
    end

    #  Progresses each in-game day
    def progress_days
      return unless @hour >= 24

      @day += 1
      @hour = 0
    end

    #  Progresses each in-game month
    def progress_months
      return unless @day > MONTH_DAYS[@month - 1]

      @month += 1
      @day = 1
    end

    #  Progresses each in-game year
    #  (does not actually increment the year value
    #   used to reset the current month to 1)
    def progress_years
      return unless @month > 12

      @month = 1
      @year += 1 if PROGRESS_YEAR
    end

    #  Converts current year into seconds
    def year_seconds
      @year * 365 * 24 * 60 * 60
    end

    #  Converts current month into seconds
    def month_seconds
      MONTH_DAYS.map.with_index(1) do |days, i|
        next 0 if i > @month

        days * 24 * 60 * 60
      end.compact.sum
    end

    #  Converts current hour into seconds
    def day_seconds
      @day * 24 * 60 * 60
    end
  end
  #-----------------------------------------------------------------------------
  #  Module function definitions for interfacing with the `Current` class
  #-----------------------------------------------------------------------------
  class << self
    #  Returns the current time class
    def now
      @now ||= Now.new
    end

    #  Used to reload the current class from a save file
    def load(value)
      @now = value
    end

    #  Progresses time to next morning
    def move_to_morning
      move_to_hour(6)
    end

    #  Progresses time to next afternoon
    def move_to_afternoon
      move_to_hour(12)
    end

    #  Progresses time to next evening
    def move_to_evening
      move_to_hour(19)
    end

    #  Progresses time to next night
    def move_to_night
      move_to_hour(22)
    end

    #  Progresses time to specified hour
    def move_to_hour(hour)
      add(days: now.seconds > hour * 60 * 60 ? 1 : 0)
      set(hour: hour, minute: 0, second: 0)
    end

    #  Adds days, hours and minutes to current time
    def add(days: 0, hours: 0, minutes: 0)
      new_minute = ((now.minute + minutes.to_i) % 60)
      new_hour   = ((now.hour + hours.to_i) % 24) + ((now.minute + minutes.to_i) / 60)
      new_day    = now.day + days + ((now.hour + hours.to_i) / 24)

      now.day    = new_day
      now.hour   = new_hour
      now.minute = new_minute
      PBDayNight.getToneInternal # refresh spritemap tones
    end

    #  Sets the current time per specified values
    def set(month: nil, day: nil, hour: nil, minute: nil, second: nil)
      now.month  = month  if month
      now.day    = day    if day
      now.hour   = hour   if hour
      now.minute = minute if minute
      now.second = second if second
      PBDayNight.getToneInternal # refresh spritemap tones
    end
  end
  #-----------------------------------------------------------------------------
end
#===============================================================================
#  Override of main Essentials function for fetching time
#===============================================================================
def pbGetTimeNow
  return GameTime.now
end

class Scene_Map
  alias with_game_time_updateSpritesets updateSpritesets
  def updateSpritesets(refresh = false)
    with_game_time_updateSpritesets(refresh)
    pbGetTimeNow.progress
  end
end
#===============================================================================
#  Save data compatibility
#===============================================================================
SaveData.register(:game_time) do
  save_value     { GameTime.now }
  load_value     { |value| GameTime.load(value) }
  new_game_value { GameTime.now }
end
