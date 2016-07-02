
# vim: et

require 'pp'

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # graphics describing logarithms
  class DepthOfFieldBackprint < Backprint

    # Hyperfocal Distance series
    H = [ 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000 ]
    RES = 1.0 # per millimeter resolution for horizontal stepping

    public
    def initialize ( img, x_mm, y_mm, w_mm, h_mm, style )
      super( img, x_mm, y_mm, h_mm )#, style )
      @w_mm = w_mm
      @scale_x = @w_mm / 51.0
      @scale_y = @h_mm / ( Math.log10( 100 ) - Math.log10( 0.001 ) )
    end # initialize

    private
    def plot ( h )
      clear = 2.0
      x = clear + 7
      y = -1
      px = -1 # to calculate last segment angle
      py = -1
      alpha = -1
      @img.pbegin()
      inline = false
      while ( x < @w_mm - clear ) do
        s = -1 + x / @scale_x
        if s < h
          dof = 2 * h * s ** 2 / ( h ** 2 - s ** 2 )
          if dof > 0
            y = @scale_y * ( Math.log10( dof ) - Math.log10( 0.001 ) )
            if ( y >= clear ) and ( y <= @h_mm - clear )
              if not inline
                @img.move( @x_mm + x, @y_mm + @h_mm - y )
                inline = true
              else
                @img.rline( @x_mm + x, @y_mm + @h_mm - y )
              end
            elsif ( y > @h_mm - clear )
              break
            end
          end
        else
          break
        end

        alpha = Math.atan( ( py - y ) / ( px - x ) )
        px = x
        py = y
        x += RES / @scale_x
      end
      @img.pend( @line_style.merge( { :stroke_width => @line_style[:stroke_width] * 4 } ) )
      if ( px != -1 ) and ( py != -1 )
        r_mm = 0.5
        x_mm = px - r_mm * Math.sin( alpha )
        y_mm = py + r_mm * Math.cos( alpha )
        @img.rtext( @x_mm + x_mm, @y_mm + @h_mm - y_mm, 0 - alpha * 180 / Math::PI, "%d" % h, @text_style.merge( { :text_anchor => 'end' } ) )
      end
    end # plot

    public
    def render()
      off_mm = 1
      fs_mm = @text_style[:font_size]
      grid = @line_style.merge( { :stroke_width => @line_style[:stroke_width] / 2 } )
      #@img.rectangle( @x_mm, @y_mm, @w_mm, @h_mm, @line_style )
      @img.line( @x_mm, @y_mm, @x_mm, @y_mm + @h_mm, @line_style )
      s = 1
      x_mm = @x_mm + @scale_x
      y_mm = @y_mm + @h_mm
      while s * @scale_x < @w_mm do
        if ( s % 5 == 0 )
          @img.line( x_mm + s * @scale_x, y_mm - off_mm, x_mm + s * @scale_x, y_mm, @line_style )
          @img.line( x_mm + s * @scale_x, @y_mm, x_mm + s * @scale_x, y_mm - off_mm - @fs_mm * 0.9 - 1, @line_style )
          @img.text( x_mm + s * @scale_x, y_mm - off_mm - 1, "%d" % s, @text_style )
        else
          @img.line( x_mm + s * @scale_x, @y_mm, x_mm + s * @scale_x, y_mm, grid )
        end
        s += 1
      end
      [0.001, 0.01, 0.1, 1, 10, 100].each do | h |
        tw_mm = h.to_s.length * @fs_mm * 0.36
        y_mm = @y_mm + @h_mm - ( Math.log10( h ) - Math.log10( 0.001 ) ) * @scale_y
#        @img.line( @x_mm, y_mm, @x_mm + @w_mm, y_mm, grid )
        @img.line( @x_mm, y_mm, @x_mm + off_mm, y_mm, @line_style )
        @img.line( @x_mm + 3 + tw_mm, y_mm, @x_mm + @w_mm, y_mm, @line_style )
        @img.text( @x_mm + 1.5, y_mm + @fs_mm / 3, "%g" % h, @text_style.merge( { :text_anchor => 'left' } ) )
        if ( h < 100 )
          (2..9).each do | frac |
            fh = frac * h
            fy_mm = @y_mm + @h_mm - ( Math.log10( fh ) - Math.log10( 0.001 ) ) * @scale_y
            @img.line( @x_mm + 3 * @scale_x / 2, fy_mm, @x_mm + ( ( h == 0.001 and frac == 2 ) ? 5.5 * @scale_x : @w_mm ), fy_mm, grid.merge( { :stroke_width => grid[:stroke_width] / 2 } ) )
          end
        end
      end
      H.each do | h | plot( h ) end
    end

    public
    def getw ( )
      return @w_mm
    end

  end # LogBackprint

end # Io::Creat::Slipstick::Backprints

