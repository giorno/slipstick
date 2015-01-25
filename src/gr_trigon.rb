
module Io::Creat::Slipstick
  module Graphics

    # renders sin-cos help graphics
    class Trigonometric

      public
      def initialize ( img, size_mm, x_mm, y_mm )
        @img       = img
        @size_mm   = size_mm
        @r_step_mm = @size_mm / 5
        @output    = @img.instance_variable_get( :@output )
        @x_mm      = x_mm # X coord of arcs center
        @y_mm      = y_mm + @size_mm # Y coord of arcs center
        render()
      end

      def render ( )
        for i in 2..5
          @img.pbegin()
            @img.move( @x_mm, @y_mm - i * @r_step_mm )
            @img.arc( @x_mm + i * @r_step_mm, @y_mm, i * @r_step_mm )
          @img.pend()
          @img.line( @x_mm, @y_mm, @x_mm, @y_mm - @size_mm )
          @img.line( @x_mm, @y_mm, @x_mm + Math::sin( Math::PI / 3 ) * @size_mm, @y_mm - Math::cos( Math::PI / 3 ) * @size_mm )
          @img.line( @x_mm, @y_mm, @x_mm + Math::sin( Math::PI / 4 ) * @size_mm, @y_mm - Math::cos( Math::PI / 4 ) * @size_mm )
          @img.line( @x_mm, @y_mm, @x_mm + Math::sin( Math::PI / 6 ) * @size_mm, @y_mm - Math::cos( Math::PI / 6 ) * @size_mm )
          @img.line( @x_mm, @y_mm, @x_mm + @size_mm, @y_mm )
        end
      end

    end # Trigonometric

  end # Graphics
end # Io::Creat::Slipstick

