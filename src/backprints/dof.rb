
# vim: et

require 'pp'

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # graphics describing logarithms
  class DepthOfFieldBackprint < Backprint

    # Hyperfocal Distance series
    H = [ 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000 ]
    RES = 1.0 # per millimeter resolution for horizontal stepping

    def initialize ( img, x_mm, y_mm, w_mm, h_mm, style )
      super( img, x_mm, y_mm, h_mm )#, style )
      @w_mm = w_mm
      @scale_x = @w_mm / 50.0
      @scale_y = @h_mm / ( Math.log10( 100 ) - Math.log10( 0.001 ) )
    end # initialize

    def plot ( h )
      clear = 2.0
      x = clear
      @img.pbegin()
      inline = false
      while ( x < @w_mm - clear ) do
        s = x / @scale_x
        if s < h
          dof = 2 * h * s ** 2 / ( h ** 2 - s ** 2 )
          if dof > 0
            y = @scale_y * ( Math.log10( dof ) - Math.log10( 0.001 ) )
            if ( y >= clear ) and( y <= @h_mm - clear )
              if not inline
                @img.move( @x_mm + x, @y_mm + @h_mm - y )
                inline = true
              else
                @img.rline( @x_mm + x, @y_mm + @h_mm - y )
              end
            end
          end
        end
        x += RES / @scale_x
      end
      @img.pend( @line_style.merge( { :stroke_width => @line_style[:stroke_width] * 4 } ) )
    end

    def render()
      grid = @line_style.merge( { :stroke_width => @line_style[:stroke_width] / 2 } )
      @img.rectangle( @x_mm, @y_mm, @w_mm, @h_mm, @line_style )
      s = 1
      while s * @scale_x < @w_mm do
        @img.line( @x_mm + s * @scale_x, @y_mm, @x_mm + s * @scale_x, @y_mm + @h_mm, grid )
        s += 1
      end
      [0.001, 0.01, 0.1, 1, 10, 100].each do | h |
        @img.line( @x_mm, @y_mm + @h_mm - ( Math.log10( h ) - Math.log10( 0.001 ) ) * @scale_y, @x_mm + @w_mm, @y_mm + @h_mm - ( Math.log10( h ) - Math.log10( 0.001 ) ) * @scale_y, grid )
#        @img.text( @x_mm, @y_mm + @h_mm - ( Math.log10( h ) - Math.log10( 0.001 ) ) * @scale_y, "%g" % h, @text_style )
      end
      H.each do | h | plot( h ) end
    end

    public
    def getw ( )
      return @w_mm
    end

  end # LogBackprint

end # Io::Creat::Slipstick::Backprints

