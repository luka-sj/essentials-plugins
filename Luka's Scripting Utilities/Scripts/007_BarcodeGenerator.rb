#===============================================================================
#  Luka's Scripting Utilities
#
#  UPC-A barcode generator
#
#  Generates a barcode bitmap following the UPC-A standard.
#    Barcodes allow a maximum of 11 digits, with the 12th digit
#    Always being the final control digit.
#===============================================================================
class BarcodeGenerator
  # Custom error
  class TypeError < ArgumentError
    def initialize
      super('Wrong input type. Only integer values allowed.')
    end
  end

  # Custom error
  class SizeError < ArgumentError
    def initialize
      super('Wrong input size. Max number of digits allowed is 11.')
    end
  end

  # Encoding for left side of digits
  # @return [Hash{Integer=>Array<Integer>}]
  L_CODE = {
    0	=> [0, 0, 0, 1, 1, 0, 1],
    1	=> [0, 0, 1, 1, 0, 0, 1],
    2	=> [0, 0, 1, 0, 0, 1, 1],
    3	=> [0, 1, 1, 1, 1, 0, 1],
    4	=> [0, 1, 0, 0, 0, 1, 1],
    5	=> [0, 1, 1, 0, 0, 0, 1],
    6	=> [0, 1, 0, 1, 1, 1, 1],
    7	=> [0, 1, 1, 1, 0, 1, 1],
    8	=> [0, 1, 1, 0, 1, 1, 1],
    9	=> [0, 0, 0, 1, 0, 1, 1]
  }.freeze

  # Encoding for right side of digits
  # @return [Hash{Integer=>Array<Integer>}]
  R_CODE = {
    0 => [1, 1, 1, 0, 0, 1, 0],
    1 => [1, 1, 0, 0, 1, 1, 0],
    2 => [1, 1, 0, 1, 1, 0, 0],
    3 => [1, 0, 0, 0, 0, 1, 0],
    4 => [1, 0, 1, 1, 1, 0, 0],
    5 => [1, 0, 0, 1, 1, 1, 0],
    6 => [1, 0, 1, 0, 0, 0, 0],
    7 => [1, 0, 0, 0, 1, 0, 0],
    8 => [1, 0, 0, 1, 0, 0, 0],
    9 => [1, 1, 1, 0, 1, 0, 0]
  }.freeze

  # Left guard for scanner alignment
  # @return [Array<Integer>]
  LEFT_GUARD  = [1, 0, 1].freeze
  # Left guard for scanner alignment
  # @return [Array<Integer>]
  MID_GUARD   = [0, 1, 0, 1, 0].freeze
  # Left guard for scanner alignment
  # @return [Array<Integer>]
  RIGHT_GUARD = [1, 0, 1].freeze

  # Width in pixels for each bar unit
  UNIT = 4
  # Color for "white" barcode lines
  COLOR_WHITE = Color.white
  # Color for "black" barcode lines
  COLOR_BLACK = Color.black

  # @param left [Integer] numeric value for the left side of the barcode
  # @param right [Integer] numeric value for the right side of the barcode
  # @param height [Integer] bitmap height
  # @param unit [Integer] bar unit width in pixels
  # @param color_white [Color] color for "white" barcode lines
  # @param color_black [Color] color for "black" barcode lines
  def initialize(number, height: 96, unit: UNIT, color_white: COLOR_WHITE, color_black: COLOR_BLACK)
    @number      = number
    @height      = height
    @unit        = unit
    @color_white = color_white
    @color_black = color_black

    validate_input
  end

  # Generates barcode bitmap
  # @return [Bitmap]
  def generate
    bitmap = Bitmap.new(encoded_digits.size * unit, height)

    encoded_digits.each_with_index do |digit, i|
      bitmap.fill_rect(i * unit, 0, unit, height, digit.zero? ? color_white : color_black)
    end

    bitmap
  end

  # Generates barcode bitmap from a trimmed value of max 5 digits
  # @return [Bitmap]
  def generate_trimmed
    bitmap = Bitmap.new(encoded_digits_trimmed.size * unit, height)

    encoded_digits_trimmed.each_with_index do |digit, i|
      bitmap.fill_rect(i * unit, 0, unit, height, digit.zero? ? color_white : color_black)
    end

    bitmap
  end

  private

  # @return [Integer]
  attr_reader :number
  # @return [Integer]
  attr_reader :height
  # @return [Integer]
  attr_reader :unit
  # @return [Color]
  attr_reader :color_white
  # @return [Color]
  attr_reader :color_black

  def validate_input
    raise TypeError.new unless number.is_a?(Integer)
    raise SizeError.new if number.digits.size > 11
  end

  # @return [Array<Integer>]
  def encoded_digits
    @encoded_digits ||= (LEFT_GUARD + left_encoded + MID_GUARD + right_encoded + RIGHT_GUARD).flatten
  end

  # @return [Array<Integer>]
  def encoded_digits_trimmed
    @encoded_digits_trimmed ||= padded_number[6...11].map { |d| R_CODE[d] }.flatten
  end

  # @return [Array<Integer>]
  def padded_number
    @padded_number ||= [0] * (11 - number.digits.size) + number.digits.reverse
  end

  # @return [Array<Integer>]
  def left_encoded
    @left_encoded ||= padded_number[0...6].map { |d| L_CODE[d] }
  end

  # @return [Array<Integer>]
  def right_encoded
    @right_encoded ||= (padded_number[6...11] + [control_digit]).flatten.map { |d| R_CODE[d] }
  end

  # Calculates the 12th, check digit for barcode
  # @return [Integer]
  def control_digit
    return @control_digit if @control_digit

    odd   = padded_number.values_at(0, 2, 4, 6, 8, 10).sum * 3
    even  = padded_number.values_at(1, 3, 5, 7, 9).sum
    total = odd + even

    @control_digit = (10 - (total % 10)) % 10
  end
end
