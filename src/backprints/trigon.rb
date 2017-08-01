
# vim: et

require_relative 'backprint'

module Io::Creat::Slipstick
  module Backprints

    # renders sin-cos help graphics
    class TrigonometricBackprint < Backprint
      STEPS = [ Math::PI / 2, Math::PI / 3, Math::PI / 4, Math::PI / 6,           0  ]
      RADS  = [          "0",        "π/6",        "π/4",        "π/3",        "π/2" ]
      COS   = [       "√0/2",       "√1/2",       "√2/2",       "√3/2",       "√4/2" ]
      SIN   = [       "√4/2",       "√3/2",       "√2/2",       "√1/2",       "√0/2" ]
      SCALE  = 0.8

      public
      def initialize ( img, x_mm, y_mm, h_mm )
        y_mm += ( 1 - SCALE ) * h_mm / 2
        h_mm *= SCALE
        @r_step_mm  = h_mm / 5
        @fs_mm = @r_step_mm / 3.5
        super( img, x_mm, y_mm + h_mm, h_mm, Io::Creat::Slipstick::STYLE[Io::Creat::Slipstick::Entity::SCALE].merge( { :"font-size" => @fs_mm } ) )
        @img        = img
        @overlap_mm = @r_step_mm * 0.1
        @output     = @img.instance_variable_get( :@output )
      end

      private
      def rtext( alpha, r_mlp, text, corr = 0.4 )
        div = text.index( '/' )
        if not div.nil?
          rtext( alpha, r_mlp, text[0..div-1], -0.29 )
          @img.line( @x_mm + Math::sin( alpha ) * ( r_mlp * @r_step_mm - 2 * @overlap_mm ), @y_mm - Math::cos( alpha ) * ( r_mlp * @r_step_mm - 2 * @overlap_mm ), @x_mm + Math::sin( alpha ) * ( r_mlp * @r_step_mm + 2 * @overlap_mm ), @y_mm - Math::cos( alpha ) * ( r_mlp * @r_step_mm + 2 * @overlap_mm ), @line_style.merge( { "stroke-linecap" => "butt" } ) )
          rtext( alpha, r_mlp, text[div+1], 0.92 )
          return
        end
        fh = corr * @text_style[:"font-size"] # font height
        @img._rtext( @x_mm + Math::sin( alpha ) * ( r_mlp * @r_step_mm ) + Math::cos( alpha ) * fh, @y_mm - Math::cos( alpha ) * ( r_mlp * @r_step_mm ) + Math::sin( alpha ) * fh, ( alpha * 180 / Math::PI ) - 90, text, @text_style )
      end

      private
      def graph ( x, y, w, h, f )
        scale = w / ( 2 * Math::PI )
        step = scale / 2
        @img.path( @line_style.clone ) do
          moveToA( x, y - f.call( 0 ) )
          ( 0..2 * Math::PI ).step( Math::PI / 18 ) do | alpha |
            lineToA( x + alpha * scale, y - f.call( alpha ) )
          end
        end
        @img.line( x - w * 0.1, y, x + w * 1.1, y, @line_style.merge( { "stroke-linecap" => "butt" } ) )
      end # graph

      public
      def render ( )

        # correct the horizontal offset
        @x_mm += 5 * @text_style[:"font-size"]

        @img._rtext( @x_mm - 5 * @text_style[:"font-size"], @y_mm - 0 * @r_step_mm, 270, "\u00a0\u00a0tan = sin/cos", @text_style.merge( { "text-anchor" => "start" } ) )
        @img._rtext( @x_mm - 4 * @text_style[:"font-size"], @y_mm - 0 * @r_step_mm, -90, "cotan = cos/sin", @text_style.merge( { "text-anchor" => "start" } ) )
        @img._rtext( @x_mm - 3 * @text_style[:"font-size"], @y_mm - 0 * @r_step_mm, -90, "\u00a0\u00a0sec = 1/cos", @text_style.merge( { "text-anchor" => "start" } ) )
        @img._rtext( @x_mm - 2 * @text_style[:"font-size"], @y_mm - 0 * @r_step_mm, -90, "cosec = 1/sin", @text_style.merge( { "text-anchor" => "start" } ) )
        @img._text( @x_mm + @h_mm, @y_mm - @h_mm + @text_style[:"font-size"], "1 = sin² + cos²", @text_style.merge( { "text-anchor" => "end" } ) )
        # cute little graphs
        @img._rtext( @x_mm - 5 * @text_style[:"font-size"], @y_mm - 3.5 * @r_step_mm, -90, "cos", @text_style )
        @img._rtext( @x_mm - 5 * @text_style[:"font-size"], @y_mm - 4.5 * @r_step_mm, -90, "sin", @text_style )
        graph( @x_mm - 4 * @text_style[:"font-size"], @y_mm - 3.5 * @r_step_mm, @r_step_mm / 1.8, @r_step_mm * 0.8, Proc.new{ | a | Math::cos( a ) } )
        graph( @x_mm - 4 * @text_style[:"font-size"], @y_mm - 4.5 * @r_step_mm, @r_step_mm / 1.8, @r_step_mm * 0.8, Proc.new{ | a | Math::sin( a ) } )

        x_mm = @x_mm
        overlap_mm = @overlap_mm
        y_mm = @y_mm
        r_step_mm = @r_step_mm
        for i in 2..5
          @img.path( @line_style.clone ) do
            moveToA( x_mm - overlap_mm, y_mm - Math::sqrt( ( i * r_step_mm ) ** 2  - overlap_mm ** 2 ) )
            arcToA( x_mm + Math::sqrt( ( i * r_step_mm ) ** 2  - overlap_mm ** 2 ), y_mm + overlap_mm, i * r_step_mm, i * r_step_mm, 0, 0, 1 )
          end
          STEPS.each do | alpha |
            @img.line( @x_mm + Math::sin( alpha ) * ( i * @r_step_mm - @overlap_mm ), @y_mm - Math::cos( alpha ) * ( i * @r_step_mm - @overlap_mm ), @x_mm + Math::sin( alpha ) * ( i * @r_step_mm + @overlap_mm ), @y_mm - Math::cos( alpha ) * ( i * @r_step_mm + @overlap_mm ), @line_style )
          end
        end

        STEPS.each_with_index do | alpha, index |
          @img.line( @x_mm + Math::sin( alpha ) * ( @r_step_mm + @overlap_mm ), @y_mm - Math::cos( alpha ) * ( @r_step_mm + @overlap_mm ), @x_mm, @y_mm, @line_style )
          # degrees
          rtext( alpha, 1.5, "%g°" % ( 90 - ( alpha * 180 / Math::PI ) ) )
          # rads
          rtext( alpha, 2.5, RADS[index] )
          # sin
          rtext( alpha, 3.5, SIN[index] )
          # cos
          rtext( alpha, 4.5, COS[index] )
        end

      end

      public
      def getw ( )
        return super() + 5 * @text_style[:"font-size"]
      end

    end # Trigonometric

  end # Backprints
end # Io::Creat::Slipstick

