
require_relative 'constants'

module Io::Creat::Slipstick
  module Graphics

    # renders sin-cos help graphics
    class Trigonometric

      public
      def initialize ( img, size_mm, x_mm, y_mm, style = Io::Creat::Slipstick::Style::DEFAULT )
        @img        = img
        @line_style = map_line_style( style[Io::Creat::Slipstick::Entity::TICK] )
        @text_style = map_text_style( style[Io::Creat::Slipstick::Entity::TICK] )
        @size_mm    = size_mm
        @r_step_mm  = @size_mm / 5
        @overlap_mm = @r_step_mm * 0.2
        @output     = @img.instance_variable_get( :@output )
        @x_mm       = x_mm # X coord of arcs center
        @y_mm       = y_mm + @size_mm # Y coord of arcs center
        render()
      end

      # convert Slipstick style to line style
      private
      def map_line_style ( from )
        return { "stroke" => from[Io::Creat::Slipstick::Key::LINE_COLOR],
                 "stroke-width" => from[Io::Creat::Slipstick::Key::LINE_WIDTH],
                 "stroke-linecap" => "butt",
                 "fill" => "none" }
      end

      # convert Slipstick style to text style
      private
      def map_text_style ( from )
        return { "fill" => from[Io::Creat::Slipstick::Key::FONT_COLOR],
                 "font-size" => from[Io::Creat::Slipstick::Key::FONT_SIZE],
                 "font-family" => from[Io::Creat::Slipstick::Key::FONT_FAMILY],
                 "font-style" => from[Io::Creat::Slipstick::Key::FONT_STYLE],
                 "text-anchor" => "middle" }
      end

      def render ( )
        for i in 2..5
          @img.pbegin()
            @img.move( @x_mm, @y_mm - i * @r_step_mm )
            @img.arc( @x_mm + i * @r_step_mm, @y_mm, i * @r_step_mm )
          @img.pend( @line_style )
          [ Math::PI / 2, Math::PI / 3, Math::PI / 4, Math::PI / 6, 0 ].each do | alpha |
            @img.line( @x_mm + Math::sin( alpha ) * ( i * @r_step_mm - @overlap_mm ), @y_mm - Math::cos( alpha ) * ( i * @r_step_mm - @overlap_mm ), @x_mm + Math::sin( alpha ) * ( i * @r_step_mm + @overlap_mm ), @y_mm - Math::cos( alpha ) * ( i * @r_step_mm + @overlap_mm ), @line_style )
          end
        end
        [ Math::PI / 2, Math::PI / 3, Math::PI / 4, Math::PI / 6, 0 ].each do | alpha |
          @img.line( @x_mm + Math::sin( alpha ) * ( @r_step_mm + @overlap_mm ), @y_mm - Math::cos( alpha ) * ( @r_step_mm + @overlap_mm ), @x_mm, @y_mm, @line_style )
        end
      end

    end # Trigonometric

  end # Graphics
end # Io::Creat::Slipstick

