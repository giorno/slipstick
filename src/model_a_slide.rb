#!/usr/bin/ruby

# vim: et

module Io::Creat::Slipstick
  module Model

    # Common logic for Sliding components
    class Slide < Component

      def render ( )
        if ( ( @layer & Component::LAYER_REVERSE ) != 0 )
          # cutting guidelines for the slipstick
          both = ( @layer & Component::LAYER_FACE ) != 0
          y_mm = !both ? @dm.sh_mm - @dm.y_mm - 2 * ( @dm.h_mm - @dm.cs_mm ) : @dm.y_mm
          @img.line( 0, y_mm + @dm.cs_mm, @dm.sw_mm, y_mm + @dm.cs_mm, @style_contours ) # cut
          @img.pline( 0, y_mm + @dm.h_mm - @dm.cs_mm, @dm.sw_mm, y_mm + @dm.h_mm - @dm.cs_mm, @style_contours, @branding.pattern ) # bend
          @img.line( 0, y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ), @dm.sw_mm, y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ), @style_contours ) # cut
          # debugging mode, outline borders of area visible in the stock
          if not @branding.release
            @img.text( @dm.sw_mm / 2, y_mm + @dm.h_mm - @dm.cs_mm - 4, @version, @style_branding )
          end
          if both
            # power scales side
            @img.line( 0, y_mm + @dm.hu_mm, @dm.sw_mm, y_mm + @dm.hu_mm, @style_contours )
            @img.line( 0, y_mm + @dm.hu_mm + @dm.hs_mm, @dm.sw_mm, y_mm + @dm.hu_mm + @dm.hs_mm, @style_contours )
            # decimal scales side
            @img.line( 0, y_mm + @dm.hu_mm + @dm.h_mm - @dm.cs_mm, @dm.sw_mm, y_mm + @dm.hu_mm + @dm.h_mm - @dm.cs_mm, @style_contours )
            @img.line( 0, y_mm + @dm.hu_mm + @dm.h_mm - @dm.cs_mm + @dm.hs_mm, @dm.sw_mm, y_mm + @dm.hu_mm + @dm.h_mm - @dm.cs_mm + @dm.hs_mm, @style_contours )
          end
        end

        super()
      end # render

    end # Slide

  end # Model

end # Io::Creat::Slipstick

