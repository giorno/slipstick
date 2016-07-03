
# vim: et

require 'pp'

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # graphics describing logarithms
  class DepthOfFieldBackprint < Backprint

    # Hyperfocal Distance series
    H = [ 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000 ]
    RES = 1.0 # per millimeter resolution for horizontal stepping
    DOF_LO = 0.001 # low limit on the DoF axis
    DOF_MULT = 10 # DoF index multiplicator
    DOF_INDEXES = 5 # number of DoF indexes
    S_LO = 0.01 # low limit on the s axis
    S_MULT = 10
    S_INDEXES = 5

    public
    def initialize ( img, x_mm, y_mm, w_mm, h_mm, style )
      super( img, x_mm, y_mm, h_mm )#, style )
      @w_mm = w_mm
      @scale_x = @w_mm / ( Math.log10( S_LO * S_MULT ** S_INDEXES ) - Math.log10( S_LO ) )
      @scale_y = @h_mm / ( Math.log10( DOF_LO * DOF_MULT ** DOF_INDEXES ) - Math.log10( DOF_LO ) )
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
        s = 10 ** ( Math.log10( S_LO ) + x / @scale_x )
        if s < h
          dof = 2 * h * s ** 2 / ( h ** 2 - s ** 2 )
          if dof > 0
            y = @scale_y * ( Math.log10( dof ) - Math.log10( DOF_LO ) )
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
      # series description
      if ( px != -1 ) and ( py != -1 )
        r_mm = 0.5
        x_mm = px - r_mm * Math.sin( alpha )
        y_mm = py + r_mm * Math.cos( alpha )
        @img.rtext( @x_mm + x_mm, @y_mm + @h_mm - y_mm, 0 - alpha * 180 / Math::PI, "%g" % h, @text_style.merge( { :text_anchor => 'end', :font_weight => 'bold' } ) )
      end
    end # plot

    public
    def render()
      of_mm = 0.5 # major gridline overflow
      fs_mm = @text_style[:font_size]
      grid = @line_style.merge( { :stroke_width => @line_style[:stroke_width] / 2 } )
      @img.line( @x_mm, @y_mm, @x_mm, @y_mm + @h_mm, @line_style )
      # horizontal axis
      (0..S_INDEXES).each do | exp |
        s = S_LO * S_MULT ** exp
        x_mm = @x_mm + ( Math.log10( s ) - Math.log10( S_LO ) ) * @scale_x
        @img.line( x_mm, @y_mm, x_mm, @y_mm + @h_mm + of_mm, @line_style )
        @img.text( x_mm, @y_mm + @h_mm + of_mm + fs_mm, "%g" % s, @text_style )
        if ( s < S_LO * S_MULT ** S_INDEXES )
          (2..9).each do | frac |
            fs = frac * s
            fx_mm = @x_mm + ( Math.log10( fs ) - Math.log10( S_LO ) ) * @scale_x
            @img.line( fx_mm, @y_mm, fx_mm, @y_mm + @h_mm, grid )
          end
        end
      end
      @img.text( @x_mm + @w_mm / 2, @y_mm + @h_mm + fs_mm, "s", @text_style.merge( { :font_weight => 'bold' } ) )
      # vertical axis
      (0..DOF_INDEXES).each do | exp |
        h = DOF_LO * DOF_MULT ** exp
        y_mm = @y_mm + @h_mm - ( Math.log10( h ) - Math.log10( DOF_LO ) ) * @scale_y
        @img.line( @x_mm - of_mm, y_mm, @x_mm + @w_mm, y_mm, @line_style )
        @img.text( @x_mm - 2 * of_mm, y_mm + 0.25 * @fs_mm, "%g" % h, @text_style.merge( { :text_anchor => 'end' } ) )
        if ( h < DOF_LO * DOF_MULT ** DOF_INDEXES )
          (2..9).each do | frac |
            fh = frac * h
            fy_mm = @y_mm + @h_mm - ( Math.log10( fh ) - Math.log10( DOF_LO ) ) * @scale_y
            @img.line( @x_mm, fy_mm, @x_mm + @w_mm, fy_mm, grid.merge( { :stroke_width => grid[:stroke_width] / 2 } ) )
          end
        end
      end
      @img.rtext( @x_mm - 2 * of_mm, @y_mm + @h_mm / 2, -90, "DoF", @text_style.merge( { :font_weight => 'bold' } ) )
      H.each do | h | plot( h ) end
    end

    public
    def getw ( )
      return @w_mm
    end

  end # LogBackprint

end # Io::Creat::Slipstick::Backprints

