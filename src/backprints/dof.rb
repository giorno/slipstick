
# vim: et

require 'pp'

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # Depth of Field (DoF) as function of subject distance s and hyperfocal
  # distance H. H is provided as discrete series.
  class DepthOfFieldBackprint < Backprint

    # Hyperfocal Distance series
    H = [ 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000, 1000000 ]
    # Parameters to render the secondary H series (fodders)
    SECONDARY = [ [ 4, 0.2], [ 2, 0.5], [ 4, 0.20 ] ]
    RES = 1.0 # per millimeter resolution for horizontal stepping
    DOF_LO = 0.001 # low limit on the DoF axis
    DOF_MULT = 10 # DoF index multiplicator
    DOF_INDEXES = 5 # number of DoF indexes
    S_LO = 0.01 # low limit on the s axis
    S_MULT = 10 # s index multiplicator
    S_INDEXES = 5 # number of s indexes

    public
    def initialize ( img, x_mm, y_mm, w_mm, h_mm, style )
      super( img, x_mm, y_mm, h_mm )#, style )
      @w_mm = w_mm
      @scale_x = @w_mm / ( Math.log10( S_LO * S_MULT ** S_INDEXES ) - Math.log10( S_LO ) )
      @scale_y = @h_mm / ( Math.log10( DOF_LO * DOF_MULT ** DOF_INDEXES ) - Math.log10( DOF_LO ) )
    end # initialize

    # H series rendering
    # if secondary is true, series is rendered as thin dashed line without any
    # label
    private
    def plot ( h, secondary = false )
      clear = 2.0
      x = clear + 7
      y = -1
      fx = -1
      fy = -1
      px = -1 # to calculate last segment angle
      py = -1
      alpha1 = -1 # angle of the first segment
      alpha99 = -1 # andle of the last segment
      scale_y = @scale_y
      h_mm = @h_mm
      x_mm = @x_mm
      y_mm = @y_mm
      w_mm = @w_mm
      scale_x = @scale_x
      @img.path( @line_style.merge( { :"stroke-width" => @line_style[:"stroke-width"] * ( secondary ? 0.5 : 2 ), :"stroke-dasharray" => ( secondary ? "1, 1" : "none" ) } ) ) do
#      @img.path( secondary ? "1, 1" : nil ) do
        inline = false
        while ( x < w_mm - clear ) do
          s = 10 ** ( Math.log10( S_LO ) + x / scale_x )
          if s < h
            dof = 2 * h * s ** 2 / ( h ** 2 - s ** 2 )
            if dof > 0
              y = scale_y * ( Math.log10( dof ) - Math.log10( DOF_LO ) )
              alpha99 = Math.atan( ( py - y ) / ( px - x ) )
              if ( inline and alpha1 == -1 )
                alpha1 = alpha99
                fx = x
                fy = y
              end
              if ( y >= clear ) and ( y <= h_mm - clear )
                if not inline
                  moveToA( x_mm + x, y_mm + h_mm - y )
                  inline = true
                else
                  lineToA( x_mm + x, y_mm + h_mm - y )
                end
              elsif ( y > h_mm - clear )
                break
              end
            end
          else
            break
          end

          px = x
          py = y
          x += RES / scale_x
        end
      end
      # series description
      if ( !secondary and ( px != -1 ) and ( py != -1 ) )
        label = ( h >= 1000 ) ? "%gk" % ( h / 1000 ) : "%g" % h
        r_mm = 0.5
        x_mm = fx - r_mm * Math.sin( alpha1 )
        y_mm = fy + r_mm * Math.cos( alpha1 )
        @img._rtext( @x_mm + x_mm, @y_mm + @h_mm - y_mm, 0 - alpha1 * 180 / Math::PI, label, @text_style.merge( { :"text-anchor" => 'start', :"font-size" => 2.0 } ) )
        x_mm = px - r_mm * Math.sin( alpha99 )
        y_mm = py + r_mm * Math.cos( alpha99 )
        @img._rtext( @x_mm + x_mm, @y_mm + @h_mm - y_mm, 0 - alpha99 * 180 / Math::PI, label, @text_style.merge( { :"text-anchor" => 'end', :"font-size" => 2.0 } ) )
      end
    end # plot

    public
    def render()
      of_mm = 0.5 # major gridline overflow
      fs_mm = @text_style[:"font-size"]
      grid = @line_style.merge( { :"stroke-width" => @line_style[:"stroke-width"] / 2 } )
      @img.line( @x_mm, @y_mm, @x_mm, @y_mm + @h_mm, @line_style )
      # horizontal axis
      (0..S_INDEXES).each do | exp |
        s = S_LO * S_MULT ** exp
        x_mm = @x_mm + ( Math.log10( s ) - Math.log10( S_LO ) ) * @scale_x
        @img.line( x_mm, @y_mm, x_mm, @y_mm + @h_mm + of_mm, @line_style )
        @img._text( x_mm, @y_mm + @h_mm + of_mm + fs_mm, "%g" % s, @text_style )
        if ( s < S_LO * S_MULT ** S_INDEXES )
          (2..9).each do | frac |
            fs = frac * s
            fx_mm = @x_mm + ( Math.log10( fs ) - Math.log10( S_LO ) ) * @scale_x
            @img.line( fx_mm, @y_mm, fx_mm, @y_mm + @h_mm + ( frac == 5 ? of_mm : 0 ), frac == 5 ? @line_style : grid )
          end
        end
      end
      # horizontal axis legend
      @img._text( @x_mm + @w_mm / 2, @y_mm + @h_mm + fs_mm, "s", @text_style.merge( { :"font-weight" => 'bold' } ) )
      # vertical axis
      (0..DOF_INDEXES).each do | exp |
        h = DOF_LO * DOF_MULT ** exp
        y_mm = @y_mm + @h_mm - ( Math.log10( h ) - Math.log10( DOF_LO ) ) * @scale_y
        @img.line( @x_mm - of_mm, y_mm, @x_mm + @w_mm, y_mm, @line_style )
        @img._text( @x_mm - 2 * of_mm, y_mm + 0.25 * @fs_mm, "%g" % h, @text_style.merge( { :"text-anchor" => 'end' } ) )
        if ( h < DOF_LO * DOF_MULT ** DOF_INDEXES )
          (2..9).each do | frac |
            fh = frac * h
            fy_mm = @y_mm + @h_mm - ( Math.log10( fh ) - Math.log10( DOF_LO ) ) * @scale_y
            @img.line( @x_mm - ( frac == 5 ? of_mm : 0 ) , fy_mm, @x_mm + @w_mm, fy_mm, frac == 5 ? @line_style : grid )
          end
        end
      end
      # vertical axis legend
      @img._rtext( @x_mm - 3 * of_mm, @y_mm + @h_mm / 2, -90, "DoF", @text_style.merge( { :"font-weight" => 'bold' } ) )
      H.each_with_index do | h, index |
        plot( h )
        # do not render last fodders
        if ( index == H.length - 1 )
          break
        end
        # main series are iterations of 1, 2 and 5, every third
        # series of secondaries has same pattern
        secondary = SECONDARY[index % 3]
        (1..secondary[0]).each do | frac |
          fh = h + h * frac * secondary[1]
          plot( fh, true )
        end
      end
    end

    public
    def getw ( )
      return @w_mm
    end

  end # LogBackprint

end # Io::Creat::Slipstick::Backprints

