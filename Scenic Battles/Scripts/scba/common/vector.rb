#===============================================================================
#  Vector calculation functionality
#===============================================================================
module SCBA
  module Common
    module Vector
      attr_reader :vector
      #-------------------------------------------------------------------------
      #  update scene backdrop position based on vector
      #-------------------------------------------------------------------------
      def update_room_position
        @vector.update

        backdrop.x      = @vector.x
        backdrop.y      = @vector.y
        backdrop.zoom_x = @vector.zoom_x
        backdrop.zoom_y = @vector.zoom_y
      end
      #-------------------------------------------------------------------------
      #  change backdrop anchor (for zooming)
      #-------------------------------------------------------------------------
      def anchor(x:, y:)
        offset_x = x.to_f / backdrop.zoom_x - backdrop.ox
        offset_y = y.to_f / backdrop.zoom_y - backdrop.oy

        backdrop.ox += offset_x
        backdrop.oy += offset_y

        @vector.set(x: @vector.x + offset_x, y: @vector.y + offset_y, duration: 1)
      end
      #-------------------------------------------------------------------------
      #  get relative distance of coordinate from backdrop anchor
      #-------------------------------------------------------------------------
      def relative_distance(x:, y:)
        offset_x = (backdrop.x - x) / backdrop.zoom_x
        offset_y = (backdrop.y - y) / backdrop.zoom_y

        [offset_x, offset_y]
      end
      #-------------------------------------------------------------------------
      #  Vector class to control positioning and animate smoothly
      #-------------------------------------------------------------------------
      class Vector
        #-----------------------------------------------------------------------
        #  class constructor
        #-----------------------------------------------------------------------
        def initialize(x:, y:, zoom_x:, zoom_y:)
          @x         = [x, x, x]
          @y         = [y, y, y]
          @zoom_x    = [zoom_x, zoom_x, zoom_x]
          @zoom_y    = [zoom_y, zoom_y, zoom_y]
          @duration  = 60
          @frame     = 0
          @animating = false
        end
        #-----------------------------------------------------------------------
        #  return vector metrics
        #-----------------------------------------------------------------------
        def x
          @x.first
        end

        def y
          @y.first
        end

        def zoom_x
          @zoom_x.first
        end

        def zoom_y
          @zoom_y.first
        end
        #-----------------------------------------------------------------------
        #  set the next vector position
        #-----------------------------------------------------------------------
        def set(x: @x.first, y: @y.first, zoom_x: @zoom_x.first, zoom_y: @zoom_y.first, duration: @duration)
          @x[2]      = x
          @x[1]      = @x.first
          @y[2]      = y
          @y[1]      = @y.first
          @zoom_x[2] = zoom_x
          @zoom_x[1] = @zoom_x.first
          @zoom_y[2] = zoom_y
          @zoom_y[1] = @zoom_y.first
          @duration  = duration
          @animating = true
          @frame     = 0
        end
        #-----------------------------------------------------------------------
        #  update vector position over time
        #-----------------------------------------------------------------------
        def update
          return unless @animating

          @x[0]      += ((@x[2] - @x[1]) / @duration).lerp
          @y[0]      += ((@y[2] - @y[1]) / @duration).lerp
          @zoom_x[0] += ((@zoom_x[2] - @zoom_x[1]) / @duration).lerp
          @zoom_y[0] += ((@zoom_y[2] - @zoom_y[1]) / @duration).lerp

          @frame += 1
          return unless @frame > @duration.lerp(inverse: true)

          @animating = false
          @frame     = 0
        end
        #-----------------------------------------------------------------------
      end
      #-------------------------------------------------------------------------
    end
  end
end
