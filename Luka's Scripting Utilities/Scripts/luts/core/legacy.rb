#===============================================================================
#  Add legacy functionality to Object
#===============================================================================
Object.define_method(:has_const?) do |const|
  const_defined?(const.to_sym)
rescue
  false
end

Object.define_method(:get_const) do |const|
  return nil unless has_const?(const)

  const_get(const.to_sym)
rescue
  nil
end

Object.define_method(:const_eql?) do |const, val|
  return false unless has_const?(const)

  get_const(const).eql?(val)
rescue
  false
end
