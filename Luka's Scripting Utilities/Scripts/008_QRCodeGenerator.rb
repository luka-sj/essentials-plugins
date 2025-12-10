#===============================================================================
#  Luka's Scripting Utilities
#
#  QR code generator
#
#  Generates a QR code bitmap, supporting versions 1-4.
#    Allows encoding of entire strings as a valid QR code.
#===============================================================================
class QRCodeGenerator
  # Class for automatic QR code version configuration.
  class Config
    # Error correction levels and their recovery percentages
    # @return [Hash{Symbol => Numeric}]
    ERROR_CORRECTION_LEVELS = {
      L: 0.07, # ~7%
      M: 0.15, # ~15%
      Q: 0.25, # ~25%
      H: 0.30  # ~30%
    }.freeze

    # @return [Integer]
    attr_reader :version
    # @return [Symbol]
    attr_reader :error_level

    # @param version [Integer] QR code version (1-40)
    # @param error_level [Symbol] Error correction level (:L, :M, :Q, :H)
    def initialize(version, error_level = :L)
      @version     = version
      @error_level = error_level
    end

    # @return [Integer]
    def size
      @size ||= 21 + 4 * (version - 1)
    end

    # @return [Integer]
    def data_codewords
      @data_codewords ||=
        { 2 => 34, 3 => 55, 4 => 80 }[version]
    end

    # @return [Integer]
    def ec_codewords
      @ec_codewords ||=
        { 2 => 10, 3 => 15, 4 => 20 }[version]
    end

    # @return [Array<Integer>]
    def alignment
      @alignment ||=
        { 2 => [18], 3 => [6, 22], 4 => [6, 26] }[version]
    end
  end

  # Reed-Solomon error correction.
  #   Adds parity symbols to protect QR data from corruption.
  class ReedSolomon
    # Galios field 256 used for Reed-Solomon error correction.
    #    It is constructed using binary numbers, where each element can be represented
    #    as a polynomial of degree less than 8 with coefficients in GF(2),
    #    which consists of the elements {0, 1}.
    class GF256
      # @return [Array<Integer>]
      attr_reader :exp
      # @return [Array<Integer>]
      attr_reader :log

      # Constructs the exponent and logarithmic components.
      def initialize
        @exp = Array.new(512)
        @log = Array.new(256)

        x = 1
        255.times do |i|
          @exp[i] = x
          @log[x] = i
          x <<= 1
          x ^= 0x11d if x & 0x100 != 0
        end
        255.upto(511) { |i| @exp[i] = @exp[i - 255] }
      end

      # Multiplies polynomial
      # @param a [Array<Integer>]
      # @param b [Array<Integer>]
      def mult(a, b)
        res = Array.new(a.size + b.size - 1, 0)

        a.each_with_index do |a_coeff, i|
          b.each_with_index do |b_coeff, j|
            res[i + j] ^= internal_mult(a_coeff, b_coeff)
          end
        end

        res
      end

      # Divides polynomial
      # @param dividend [Array<Integer>]
      # @param divisor [Array<Integer>]
      def div(dividend, divisor)
        res = dividend.dup

        divisor_degree = divisor.size - 1
        divisor_lead = divisor[0]

        (0..(res.size - divisor.size)).each do |i|
          coef = res[i]
          next if coef.zero?

          factor = log[coef] - log[divisor_lead]
          divisor.each_with_index do |d, j|
            next if d.zero?

            res[i + j] ^= exp[(log[d] + factor) % 255]
          end
        end

        res[-divisor_degree..-1]
      end

      private

      # Internal multiplication
      # @param x [Integer]
      # @param y [Integer]
      def internal_mult(x, y)
        return 0 if x.zero? || y.zero?

        exp[log[x] + log[y]]
      end
    end

    # Constructs the CF256 table
    # @param config [QRCodeGenerator::Config]
    def initialize(config)
      @config = config
      @gf256  = GF256.new
    end

    # Applies error correction to given data
    # @param data [Array<String>] data in bytes
    def ec(data)
      padded = data + Array.new(config.ec_codewords, 0)

      gf256.div(padded, generator_poly)
    end

    private

    # @return [QRCodeGenerator::ReedSolomon::GF256]
    attr_reader :gf256
    # @return [QRCodeGenerator::Config]
    attr_reader :config

    # @return [Array<Array<Integer>>]
    def generator_poly
      poly = [1]
      config.ec_codewords.times { |i| poly = gf256.mult(poly, [1, gf256.exp[i]]) }

      poly
    end
  end

  # Data encoder class.
  #   Converts input string into encoded bytes.
  class Encoder
    # Padded bytes
    # @return [Array<String>]
    PAD_BYTES = ["11101100", "00010001"].freeze

    # @param data [String]
    # @param config [QRCodeGenerator::Config]
    def initialize(data, config)
      @data   = data
      @config = config
    end

    # Returns an array of encoded strings
    # @return [Array<String>]
    def encode
      (encoded_data + ec_bytes).map { |b| sprintf("%08b", b) }.join
    end

    private

    # @return [String]
    attr_reader :data
    # @return [QRCodeGenerator::Config]
    attr_reader :config

    # Returns the input data in encoded form (bytes)
    # @return [Array<String>]
    def encoded_data
      return @bytes if @bytes

      bits = "0100" # Byte mode
      bits += sprintf("%08b", data.bytesize)
      data.bytes.each { |b| bits += sprintf("%08b", b) }

      term_len = [4, max_bits - bits.length].min
      bits += "0" * term_len
      bits += "0" * ((8 - bits.length % 8) % 8)

      i = 0
      while bits.length < max_bits
        bits += PAD_BYTES[i % 2]
        i += 1
      end

      @bytes = bits_to_bytes(bits)
    end

    # @return [Integer]
    def max_bits
      @max_bits ||= config.data_codewords * 8
    end

    # @return [Array<String>]
    def bits_to_bytes(bits)
      bits.chars.each_slice(8).map { |chunk| chunk.join.to_i(2) }
    end

    # Returns error correction bytes
    # @return [Array<String>]
    def ec_bytes
      @ec_bytes ||= ReedSolomon.new(config).ec(encoded_data)
    end
  end

  # Blank matrix class.
  #   Creates default QR metrics with finder and alignment patterns.
  class Matrix
    # Alignment pattern
    # @return [Array<Array<Integer>>]
    ALIGNMENT_PATTERN = [
      [1,1,1,1,1],
      [1,0,0,0,1],
      [1,0,1,0,1],
      [1,0,0,0,1],
      [1,1,1,1,1]
    ].freeze

    # Finder pattern (outer 3 points)
    # @return [Array<Array<Integer>>]
    FINDER_PATTERN = [
      [1,1,1,1,1,1,1],
      [1,0,0,0,0,0,1],
      [1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1],
      [1,0,0,0,0,0,1],
      [1,1,1,1,1,1,1]
    ].freeze

    # @return [Array<Array<Integer>>]
    attr_reader :matrix
    # @return [QRCodeGenerator::Config]
    attr_reader :config

    # Initializes 2D matrix
    def initialize(config)
      @config = config
      @matrix = Array.new(config.size) { Array.new(config.size, nil) }

      setup
    end

    # @return [Integer]
    def size
      config.size
    end

    # Check overlap with finder pattern areas (including separators)
    # @param row [Integer]
    # @param col [Integer]
    # @return [Boolean]
    def finder_overlap?(row, col)
      return true if (row <= 8 && col <= 8)         # Top-left
      return true if (row <= 8 && col >= size - 8)  # Top-right
      return true if (row >= size - 8 && col <= 8)  # Bottom-left

      false
    end

    private

    # Configures the initial matrix setup
    def setup
      place_finder(0, 0)         # Top-left
      place_finder(size - 7, 0)  # Top-right
      place_finder(0, size - 7)  # Bottom-left
      place_separators
      place_alignment_patterns
      place_timing
      place_dark_module
    end

    # Places finter pattern
    def place_finder(x, y)
      7.times do |dy|
        7.times do |dx|
          matrix[y + dy][x + dx] = FINDER_PATTERN[dy][dx].positive?
        end
      end
    end

    # Places separators around finder patterns
    def place_separators
      # Top-left finder pattern separator
      8.times do |i|
        matrix[7][i] = false
        matrix[i][7] = false
      end

      # Top-right finder pattern separator
      8.times do |i|
        matrix[7][size - 1 - i] = false
        matrix[i][size - 8] = false
      end

      # Bottom-left finder pattern separator
      8.times do |i|
        matrix[size - 8][i] = false
        matrix[size - 1 - i][7] = false
      end
    end

    # Places alignment pattern
    def place_alignment_patterns
      # For version 2, there's only one alignment pattern
      if config.version == 2
        place_alignment(config.alignment[0], config.alignment[0])
        return
      end

      # For versions 3+, create grid of alignment patterns
      config.alignment.each do |row_pos|
        config.alignment.each do |col_pos|
          # Skip positions that overlap with finder patterns
          next if finder_overlap?(row_pos, col_pos)

          place_alignment(row_pos, col_pos)
        end
      end
    end

    def place_alignment(center_x, center_y)
      (-2..2).each do |dy|
        (-2..2).each do |dx|
          row = center_y + dy
          col = center_x + dx
          next if row < 0 || col < 0 || row >= size || col >= size

          matrix[row][col] = ALIGNMENT_PATTERN[dy + 2][dx + 2].positive?
        end
      end
    end

    # Places timing pattern
    def place_timing
      (8...(size - 8)).each do |i|
        matrix[6][i] = i.even?
        matrix[i][6] = i.even?
      end
    end

    # Places dark module
    def place_dark_module
      # matrix[4 * config.version - 1][8] = true
      matrix[8][4 * config.version + 9] = true
    end
  end

  class << self
    # Method to recommend version for given data
    # @param data [String]
    # @param mode [Symbol]
    def recommend_version(data, mode = :byte)
      data_length = mode == :byte ? data.bytesize : data.length

      (1..7).each do |version|
        capacity = version_capacity(version, mode)
        return version if capacity && data_length <= capacity
      end

      # Data too large for versions 1-4
      nil
    end

    # Method to get version capacity information
    # @param version [Integer]
    # @param mode [Symbol]
    def version_capacity(version, mode = :byte)
      config = Config.new(version)
      return nil unless config.data_codewords

      case mode
      when :numeric
        (config.data_codewords * 8 * 0.3).to_i  # ~3.32 bits per digit
      when :alphanumeric
        (config.data_codewords * 8 * 0.18).to_i # ~5.5 bits per char
      when :byte
        overhead = version <= 4 ? 2 : 3
        config.data_codewords - overhead # Reserve overhead for mode + length
      else
        config.data_codewords
      end
    end
  end

  # Size of the encoded byte in pixels
  UNIT_SIZE = 4
  # Size of non-data pixels around the generated QR code
  QUIET_ZONE_SIZE = 4
  # Color for "white" barcode lines
  COLOR_WHITE = Color.white
  # Color for "black" barcode lines
  COLOR_BLACK = Color.black

  # @param data [String]
  # @param version [String] QR code version used
  # @param unit_size [Integer] data unit unit width/height in pixels
  # @param color_white [Color] color for "empty" QR code data
  # @param color_black [Color] color for "full" QR code data
  def initialize(data, version: nil, unit_size: UNIT_SIZE, color_white: COLOR_WHITE, color_black: COLOR_BLACK)
    @config      = Config.new(version || select_version(data))
    @unit_size   = unit_size
    @color_white = color_white
    @color_black = color_black

    raise ArgumentError, "Unsupported version: #{@config.version}" unless @config.data_codewords
    raise ArgumentError, "Data too large for version #{@config.version}" if data.bytesize > @config.data_codewords

    @matrix = Matrix.new(@config)

    map_bits(Encoder.new(data, @config).encode)
    apply_mask
    apply_format_info
  end

  # Generates QR code bitmap
  # @return [Bitmap]
  def generate
    bitmap = Bitmap.new(bitmap_size, bitmap_size)
    bitmap.fill_rect(0, 0, bitmap_size, bitmap_size, color_white)

    matrix.size.times do |row|
      matrix.size.times do |col|
        color = matrix.matrix[row][col] ? color_black : color_white
        x = (col + QUIET_ZONE_SIZE) * unit_size
        y = (row + QUIET_ZONE_SIZE) * unit_size
        bitmap.fill_rect(x, y, unit_size, unit_size, color)
      end
    end

    bitmap
  end

  private

  XOR_MASK = 0b101010000010010
  GEN_POLY = 0b10100110111

  # @return [QRCodeGenerator::Config]
  attr_reader :config
  # @return [QRCodeGenerator::Matrix]
  attr_reader :matrix
  # @return [Integer]
  attr_reader :unit_size
  # @return [Color]
  attr_reader :color_white
  # @return [Color]
  attr_reader :color_black

  # Select best suited QR version for input data
  def select_version(data)
    self.class.recommend_version(data) || raise(ArgumentError, 'Data too large for supported versions (2-4)')
  end

  # Maps encoded bits to QR code matrix
  # @param bits [Array<String>]
  def map_bits(bits)
    col = matrix.size - 1
    dir_up = true
    bit_index = 0

    while col > 0 && bit_index < bits.length
      # Skip timing column
      if col == 6
        col -= 1
        next
      end

      # Determine row order based on direction
      rows = dir_up ? (matrix.size - 1).downto(0) : (0...matrix.size)

      rows.each do |row|
        # Process two columns: right then left
        2.times do |offset|
          c = col - offset
          next if c < 0
          next if reserved?(row, c)

          if bit_index < bits.length
            matrix.matrix[row][c] = bits[bit_index].eql?('1')
            bit_index += 1
          end
        end
      end

      dir_up = !dir_up
      col -= 2
    end
  end

  # Applies mask for zero mask pattern
  def apply_mask
    matrix.size.times do |row|
      matrix.size.times do |col|
        next if reserved?(row, col)

        matrix.matrix[row][col] = !matrix.matrix[row][col] if ((row + col) % 2).zero?
      end
    end
  end

  # @param row [Integer]
  # @param col [Integer]
  def reserved?(row, col)
    # Finder patterns (7x7) and separators (8x8)
    return true if (row <= 8 && col <= 8)               # Top-left
    return true if (row <= 8 && col >= matrix.size - 8) # Top-right
    return true if (row >= matrix.size - 8 && col <= 8) # Bottom-left
    # Timing patterns
    return true if row == 6 || col == 6
    # Alignment patterns
    return true if alignment_pattern_area?(row, col)
    # Dark module
    return true if row == 8 && col == 4 * config.version - 9
    # Format information areas
    return true if format_reserved?(row, col)

    false
  end

  # @param row [Integer]
  # @param col [Integer]
  def format_reserved?(row, col)
    # Horizontal format info
    return true if row == 8 && col <= 8
    # Vertical format info
    return true if col == 8 && row <= 8
    # Top-right format info
    return true if row == 8 && col >= matrix.size - 8
    # Bottom-left format info
    return true if col == 8 && row >= matrix.size - 8

    false
  end

  # @param row [Integer]
  # @param col [Integer]
  def alignment_pattern_area?(row, col)
    # Single alignment pattern
    if config.version == 2
      center = config.alignment[0]
      return (row >= center - 2 && row <= center + 2) && (col >= center - 2 && col <= center + 2)
    end

    # Multiple alignment patterns
    config.alignment.each do |row_pos|
      config.alignment.each do |col_pos|
        next if matrix.finder_overlap?(row_pos, col_pos)

        if (row >= row_pos - 2 && row <= row_pos + 2) && (col >= col_pos - 2 && col <= col_pos + 2)
          return true
        end
      end
    end

    false
  end

  def apply_format_info
    # Error correction level L = 01, mask pattern = 000
    format_info = (0b01 << 3) | 0

    # BCH(15,5) error correction
    format_poly = format_info << 10

    14.downto(10) do |i|
      format_poly ^= GEN_POLY << (i - 10) if ((format_poly >> i) & 1).positive?
    end

    format_info = (format_info << 10) | (format_poly & 0x3ff)
    format_info ^= XOR_MASK

    # Place format info bits
    format_bits = 15.times.map { |i| (format_info >> (14 - i)) & 1 }

    # Horizontal format info (around top-left finder pattern)
    # Skip position 6 (timing pattern)
    bit_index = 0
    9.times do |col|
      next if col == 6  # Skip timing pattern column

      matrix.matrix[8][col] = format_bits[bit_index].positive?
      bit_index += 1
    end

    # Vertical format info (around top-left finder pattern)
    # Skip position 6 (timing pattern)
    7.downto(0) do |row|
      next if row == 6  # Skip timing pattern row

      matrix.matrix[row][8] = format_bits[bit_index].positive?
      bit_index += 1
    end

    # Top-right format info (horizontal)
    7.times do |i|
      matrix.matrix[8][matrix.size - 1 - i] = format_bits[i].positive?
    end

    # Bottom-left format info (vertical)
    8.times do |i|
      matrix.matrix[matrix.size - 1 - i][8] = format_bits[14 - i].positive?
    end
  end

  # @return [Integer]
  def bitmap_size
    @bitmap_size ||= (config.size + 2 * QUIET_ZONE_SIZE) * unit_size
  end
end
