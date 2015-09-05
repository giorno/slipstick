
# vim: et

require_relative 'backprint'

module Io::Creat::Slipstick
  module Backprints

    # renders sin-cos help graphics
    class TrigonometricBackprint < Backprint
      STEPS = [ Math::PI / 2, Math::PI / 3, Math::PI / 4, Math::PI / 6,           0  ]
      RADS  = [          "0",        "π/6",        "π/4",        "π/3",        "π/2" ]
      COS   = [  "\u221b0/2",  "\u221b1/2",  "\u221b2/2",  "\u221b3/2",  "\u221b4/2" ]
      SIN   = [  "\u221b4/2",  "\u221b3/2",  "\u221b2/2",  "\u221b1/2",  "\u221b0/2" ]
      SCALE  = 0.8

      public
      def initialize ( img, x_mm, y_mm, h_mm )
        y_mm += ( 1 - SCALE ) * h_mm / 2
        h_mm *= SCALE
        @r_step_mm  = h_mm / 5
        @fs_mm = @r_step_mm / 3.5
        super( img, x_mm, y_mm + h_mm, h_mm, Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::SCALE].merge( { :font_size => @fs_mm } ) )
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
        fh = corr * @text_style[:font_size] # font height
        @img.rtext( @x_mm + Math::sin( alpha ) * ( r_mlp * @r_step_mm ) + Math::cos( alpha ) * fh, @y_mm - Math::cos( alpha ) * ( r_mlp * @r_step_mm ) + Math::sin( alpha ) * fh, ( alpha * 180 / Math::PI ) - 90, text, @text_style )
      end

      private
      def graph ( x, y, w, h, f )
        scale = w / ( 2 * Math::PI )
        step = scale / 2
        @img.pbegin()
          @img.move( x, y - f.call( 0 ) )
          ( 0..2 * Math::PI ).step( Math::PI / 18 ) do | alpha |
            @img.rline( x + alpha * scale, y - f.call( alpha ) )
          end
        @img.pend( @line_style )
        @img.line( x - w * 0.1, y, x + w * 1.1, y, @line_style.merge( { "stroke-linecap" => "butt" } ) )
      end

      public
      def render ( )

        # correct the horizontal offset
        @x_mm += 5 * @text_style[:font_size]

        @img.rtext( @x_mm - 5 * @text_style[:font_size], @y_mm - 0 * @r_step_mm, -90, "\u00a0\u00a0tan = sin/cos", @text_style.merge( { "text-anchor" => "start" } ) )
        @img.rtext( @x_mm - 4 * @text_style[:font_size], @y_mm - 0 * @r_step_mm, -90, "cotan = cos/sin", @text_style.merge( { "text-anchor" => "start" } ) )
        @img.rtext( @x_mm - 3 * @text_style[:font_size], @y_mm - 0 * @r_step_mm, -90, "\u00a0\u00a0sec = 1/cos", @text_style.merge( { "text-anchor" => "start" } ) )
        @img.rtext( @x_mm - 2 * @text_style[:font_size], @y_mm - 0 * @r_step_mm, -90, "cosec = 1/sin", @text_style.merge( { "text-anchor" => "start" } ) )
        @img.text( @x_mm + @h_mm, @y_mm - @h_mm + @text_style[:font_size], "1 = sin² + cos²", @text_style.merge( { "text-anchor" => "end" } ) )
        # cute little graphs
        @img.rtext( @x_mm - 5 * @text_style[:font_size], @y_mm - 3.5 * @r_step_mm, -90, "cos", @text_style )
        @img.rtext( @x_mm - 5 * @text_style[:font_size], @y_mm - 4.5 * @r_step_mm, -90, "sin", @text_style )
        graph( @x_mm - 4 * @text_style[:font_size], @y_mm - 3.5 * @r_step_mm, @r_step_mm / 1.8, @r_step_mm * 0.8, Proc.new{ | a | Math::cos( a ) } )
        graph( @x_mm - 4 * @text_style[:font_size], @y_mm - 4.5 * @r_step_mm, @r_step_mm / 1.8, @r_step_mm * 0.8, Proc.new{ | a | Math::sin( a ) } )

        for i in 2..5
          @img.pbegin()
            @img.move( @x_mm - @overlap_mm, @y_mm - Math::sqrt( ( i * @r_step_mm ) ** 2  - @overlap_mm ** 2 ) )
            @img.arc( @x_mm + Math::sqrt( ( i * @r_step_mm ) ** 2  - @overlap_mm ** 2 ), @y_mm + @overlap_mm, i * @r_step_mm )
          @img.pend( @line_style )
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
        return super() + 5 * @text_style[:font_size]
      end

    end # Trigonometric

  end # Backprints
end # Io::Creat::Slipstick

