#===============================================================================
#  Luka's Scripting Utilities
#
#  Core extensions for the `Numeric` class
#===============================================================================
class ::Numeric
  # Interpolates number based on current frame rates
  # @param inverse [Boolean]
  # @return [Numeric]
  def lerp(inverse: false)
    # time per frame, for a target of 60 FPS
    target = 60.0 / Graphics.average_frame_rate
    target = 1.0 / target if inverse

    self * target
  end

  # @return [Boolean]
  def blank?
    zero?
  end

  # @return [Boolean]
  def present?
    !blank?
  end

  # @return [Integer]
  def minute
    minutes
  end

  # @return [Integer]
  def minutes
    to_i * 60
  end

  # @return [Integer]
  def hour
    hours
  end

  # @return [Integer]
  def hours
    to_i * 60 * 60
  end

  # @return [Integer]
  def day
    days
  end

  # @return [Integer]
  def days
    to_i * 24 * 60 * 60
  end
end
