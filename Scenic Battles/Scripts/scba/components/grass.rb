#===============================================================================
#  Grass components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Grass
      include SCBA::Common::Room
      #-------------------------------------------------------------------------
      #  construct scene trees
      #-------------------------------------------------------------------------
      def construct
        return unless @data.key?(:elements)

        bitmap = LUTS::SpriteHash.bitmap(
          "Graphics/Battlebacks/Components/#{@data[:bitmap] || 'tallGrass'}"
        )

        @data[:elements].times do |i|
          x0 = @data.key?(:mirror) && @data[:mirror][i] ? bitmap.width : 0
          x1 = @data.key?(:mirror) && @data[:mirror][i] ? -bitmap.width : bitmap.width

          @sprites.add(
            i,
            bitmap: Bitmap.new(bitmap.width, bitmap.height).stretch_blt(bitmap.rect, bitmap, Rect.new(x0, 0, x1, bitmap.height)),
            anchor: :bottom_middle,
            ex: @data.value(:x)&.value(i) || 0,
            ey: @data.value(:y)&.value(i) || 0,
            z: @data.value(:z)&.value(i),
            param: @data.value(:zoom)&.value(i) || 1
          )
          @room.set_color(@backdrop, @sprites[i], @data.value(:colorize) || true)
          @sprites[i].memorize_bitmap
        end
      end
      #-------------------------------------------------------------------------
      #  calculate sprite positions
      #-------------------------------------------------------------------------
      def position_zoom
        @sprites.each do |_key, sprite|
          sprite.zoom_x = sprite.param * backdrop.zoom_x
          sprite.zoom_y = sprite.param * backdrop.zoom_x
        end
      end
      #-------------------------------------------------------------------------
    end
  end
end
