#===============================================================================
#  Callback wrapper with variable passing
#===============================================================================
class CallbackWrapper
  @params = {}
  #-----------------------------------------------------------------------------
  #  execute callback
  #-----------------------------------------------------------------------------
  def execute(block, *args)
    @params.each do |key, value|
      args.instance_variable_set("@#{key}", value)
    end
    args.instance_eval(&block)
  end
  #-----------------------------------------------------------------------------
  #  set instance variables
  #-----------------------------------------------------------------------------
  def set(params)
    @params = params
  end
  #-----------------------------------------------------------------------------
end
