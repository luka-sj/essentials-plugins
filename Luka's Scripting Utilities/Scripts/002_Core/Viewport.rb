#===============================================================================
#  Extensions for the `Viewport` class
#===============================================================================
class ::Viewport
  include LUTS::Concerns::Animatable
  #-----------------------------------------------------------------------------
  #  returns an array of all sprites belonging to target viewport
  #-----------------------------------------------------------------------------
  def sprites
    [].tap do |array|
      ObjectSpace.each_object(Sprite) do |obj|
        array << obj if obj.viewport.eql?(self)
      end
    end
  end
  #-----------------------------------------------------------------------------
  #  removes any applied color
  #-----------------------------------------------------------------------------
  def reset_color
    color = Color.new(0, 0, 0, 0)
  end
  #-----------------------------------------------------------------------------
  #  gets width of viewport
  #-----------------------------------------------------------------------------
  def width
    rect.width
  end
  #-----------------------------------------------------------------------------
  #  gets height of viewport
  #-----------------------------------------------------------------------------
  def height
    rect.height
  end

  def alpha
    color.alpha
  end

  def alpha=(val)
    color.alpha = val
  end
  #-----------------------------------------------------------------------------
end
