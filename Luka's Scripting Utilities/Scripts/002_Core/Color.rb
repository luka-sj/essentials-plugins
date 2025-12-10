#===============================================================================
#  Luka's Scripting Utilities
#
#  Core extensions for the `Color` class
#===============================================================================
class ::Color
  # Allows color components to be animated easily
  include ::LUTS::Concerns::Animatable

  # @return [Color]
  def self.blank
    Color.new(0, 0, 0, 0)
  end

  # @return [Color]
  def self.dark_gray
    Color.new(64, 64, 64)
  end

  # @param amt [Numeric]
  # @return [Color]
  def darken(amt = 0.2)
    r = red - red * amt
    g = green - green * amt
    b = blue - blue * amt

    Color.new(r, g, b)
  end

  # @return [Boolean]
  def blank?
    red.zero? && green.zero? && blue.zero? && alpha.zero?
  end

  # @return [Boolean]
  def present?
    !blank?
  end
end
