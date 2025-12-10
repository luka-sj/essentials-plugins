#===============================================================================
#  Luka's Scripting Utilities
#
#  Core extensions for the `Hash` class
#===============================================================================
class ::Hash
  # @param key [Object]
  # @return [Object] value associated with key
  def value(key)
    self[key]
  end

  # Merges many hashes into self
  # @param hashes [Array<Hash>]
  # @return [Hash]
  def merge_many(*hashes)
    tap do |output|
      hashes.each do |hash|
        hash.each do |key, value|
          output[key] = value
        end
      end
    end
  end

  # @return [Boolean]
  def blank?
    keys.empty?
  end

  # @return [Boolean]
  def present?
    !blank?
  end
end
