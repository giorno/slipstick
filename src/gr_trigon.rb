
require_relative 'constants'

module Io::Creat::Slipstick
  module Graphics

    # renders sin-cos help graphics
    class Trigonometric
      STEPS = [ Math::PI / 2, Math::PI / 3, Math::PI / 4, Math::PI / 6, 0 ]
      RADS = [ "0", "π/6", "π/4", "π/3", "π/2" ]
      COS = [ "√0/2", "√1/2", "√2/2", "√3/2", "√4/0" ]
      SIN = [ "√4/2", "√3/2", "√2/2", "√1/2", "√0/0" ]

      public
      def initialize ( img, size_mm, x_mm, y_mm, style = Io::Creat::Slipstick::Style::DEFAULT )
        @img        = img
        @size_mm    = size_mm
        @r_step_mm  = @size_mm / 5
        @line_style = map_line_style( style[Io::Creat::Slipstick::Entity::TICK] )
        @text_style = map_text_style( style[Io::Creat::Slipstick::Entity::LOTICK].merge( { Io::Creat::Slipstick::Key::FONT_SIZE => @r_step_mm / 3.5 } ) )
        @overlap_mm = @r_step_mm * 0.1
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
      
      private
      def rtext( alpha, r_mlp, text, corr = 0.4 )
        div = text.index( '/' )
        if not div.nil?
          rtext( alpha, r_mlp, text[0..div-1], -0.29 )
          @img.line( @x_mm + Math::sin( alpha ) * ( r_mlp * @r_step_mm - 2 * @overlap_mm ), @y_mm - Math::cos( alpha ) * ( r_mlp * @r_step_mm - 2 * @overlap_mm ), @x_mm + Math::sin( alpha ) * ( r_mlp * @r_step_mm + 2 * @overlap_mm ), @y_mm - Math::cos( alpha ) * ( r_mlp * @r_step_mm + 2 * @overlap_mm ), @line_style )
          rtext( alpha, r_mlp, text[div+1], 0.92 )
          return
        end
        fh = corr * @text_style["font-size"] # font height
        @img.rtext( @x_mm + Math::sin( alpha ) * ( r_mlp * @r_step_mm ) + Math::cos( alpha ) * fh, @y_mm - Math::cos( alpha ) * ( r_mlp * @r_step_mm ) + Math::sin( alpha ) * fh, ( alpha * 180 / Math::PI ) - 90, text, @text_style )
      end

      private
      def graph ( x, y, w, h, f )
        scale = w / ( 2 * Math::PI )
        step = scale / 2
        @img.pbegin()
          @img.move( x, y - f.call( 0 ) )
          ( 0..2 * Math::PI ).step( Math::PI / 9 ) do | alpha |
            @img.rline( x + alpha * scale, y - f.call( alpha ) )
          end
        @img.pend( @line_style )
        @img.line( x - w * 0.1, y, x + w * 1.1, y, @line_style )
      end

      def render ( )

        for i in 2..5
          @img.pbegin()
            @img.move( @x_mm, @y_mm - i * @r_step_mm )
            @img.arc( @x_mm + i * @r_step_mm, @y_mm, i * @r_step_mm )
          @img.pend( @line_style )
          STEPS.each do | alpha |
            @img.line( @x_mm + Math::sin( alpha ) * ( i * @r_step_mm - @overlap_mm ), @y_mm - Math::cos( alpha ) * ( i * @r_step_mm - @overlap_mm ), @x_mm + Math::sin( alpha ) * ( i * @r_step_mm + @overlap_mm ), @y_mm - Math::cos( alpha ) * ( i * @r_step_mm + @overlap_mm ), @line_style )
          end
        end

        STEPS.each_with_index do | alpha, index |
          @img.line( @x_mm + Math::sin( alpha ) * ( @r_step_mm + @overlap_mm ), @y_mm - Math::cos( alpha ) * ( @r_step_mm + @overlap_mm ), @x_mm, @y_mm, @line_style )
          # degrees
          rtext( alpha, 1.5, "\u00a0%g°" % ( 90 - ( alpha * 180 / Math::PI ) ) )
          # rads
          rtext( alpha, 2.5, RADS[index] )
          # sin
          rtext( alpha, 3.5, SIN[index] )
          # cos
          rtext( alpha, 4.5, COS[index] )
        end

        @img.rtext( @x_mm - 2 * @text_style["font-size"], @y_mm - 3.5 * @r_step_mm, -90, "sin", @text_style )
        @img.rtext( @x_mm - 2 * @text_style["font-size"], @y_mm - 4.5 * @r_step_mm, -90, "cos", @text_style )
        graph( @x_mm - 5 * @text_style["font-size"], @y_mm - 3.5 * @r_step_mm, @r_step_mm / 1.8, @r_step_mm * 0.8, Proc.new{ | a | Math::sin( a ) } )
        graph( @x_mm - 5 * @text_style["font-size"], @y_mm - 4.5 * @r_step_mm, @r_step_mm / 1.8, @r_step_mm * 0.8, Proc.new{ | a | Math::cos( a ) } )
      end

    end # Trigonometric

  end # Graphics
end # Io::Creat::Slipstick

