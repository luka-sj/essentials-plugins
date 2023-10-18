#===============================================================================
#  Sprite components for dynamic battle scenes
#===============================================================================
module SCBA
  module Components
    class Sprite
      include SCBA::Common::Room
      #-------------------------------------------------------------------------
      #  construct scene trees
      #-------------------------------------------------------------------------
      def construct
        return unless @data[:bitmap]

        @sprites.add(:component, **{}.tap do |options|
          @data.each do |key, value|
            next options[:bitmap] = bitmap_arguments(value) if key.eql?(:bitmap)
            next options[:type]   = value.to_s.camelize if key.eql?(:type)
            next options[:ex]     = value if key.eql?(:x)
            next options[:ey]     = value if key.eql?(:y)
            next options[:zx]     = value if key.eql?(:zoom_x)
            next options[:zy]     = value if key.eql?(:zoom_y)
            next options[:param]  = value if key.eql?(:zoom)
            next options[:z]      = [value, 40].min if key.eql?(:z)

            options[key] = value
          end

          options[:anchor] = :bottom_middle unless @data[:ox] || @data[:oy]
        end)

        # apply color to sprite
        @room.set_color(backdrop, @sprites.hash.component) if @data[:colorize].eql?(true)
        @sprites.hash.component.colorize(@data[:colorize], amount: @data[:colorize].alpha) if @data[:colorize].is_a?(Color)
        @sprites.hash.component.memorize_bitmap
      end
      #-------------------------------------------------------------------------
      #  calculate sprite positions
      #-------------------------------------------------------------------------
      def position_zoom
        return super if @data[:flat].eql?(true)

        @sprites.each do |_key, sprite|
          sprite.zoom_x = sprite.param * backdrop.zoom_x
          sprite.zoom_y = sprite.param * backdrop.zoom_x
        end
      end

      private
      #-------------------------------------------------------------------------
      #  map bitamp initialization arguments
      #-------------------------------------------------------------------------
      def bitmap_arguments(value)
        { file: "Graphics/Battlebacks/Components/#{value}" }.tap do |args|
          args[:vertical] = @data[:vertical] if @data[:vertical]
          args[:frames]   = @data[:frames] if @data[:frames]
          args[:pulse]    = @data[:pulse] if @data[:pulse]
          args[:speed]    = @data[:speed] if @data[:speed]
        end
      end
      #-------------------------------------------------------------------------
    end
  end
end
