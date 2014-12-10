#!/usr/bin/ruby

require 'rasem'

module Io
  module Creat
    module Slipstick
      module Utils

        # draws a pocket feature for stator element, needed because Inkscape
        # does not support fillet tool in the main codebase
        class PocketDrawer
          public
          def initialize ( r_mm, d_mm, h_mm, w_mm, alpha_deg = 90.0, off_y_mm = nil )
            @r_mm = r_mm # arc diameter
            @d_mm = d_mm # horizontal depth
            @h_mm = h_mm # vertical height
            @w_mm = w_mm # wertical width
            @off_y_mm = off_y_mm.nil? ? h_mm / 2.0 : off_y_mm # zero point
            @alpha = ( alpha_deg / 2.0 ) * Math::PI / 180
	    @off_x_mm = 10.0
            @img = Rasem::SVGImage.new( "%dmm" % ( @d_mm + @off_x_mm + 2 ), "%dmm" % ( @off_x_mm + @h_mm ) )
          end

          protected
          def line ( x1_mm, y1_mm, x2_mm, y2_mm )
#	    $stderr.puts( "%g %g %g %g" % [x1_mm, y1_mm, x2_mm, y2_mm] )
            @img.line "%g" % ( @off_x_mm + @d_mm + x1_mm ), "%g" % ( @off_x_mm + @off_y_mm + y1_mm ), "%g" % ( @off_x_mm + @d_mm + x2_mm ), "%g" % ( @off_x_mm + @off_y_mm + y2_mm ), { :stroke => 'black', :stroke_width=>0.25}
          end

          # missing feature in rasem library
          protected
          def arc ( xs_mm, ys_mm, xe_mm, ye_mm, r_mm )
            @img.instance_variable_get( :@output ) << %Q{<path d="M#{@off_x_mm + @d_mm + xs_mm},#{@off_x_mm + @off_y_mm + ys_mm} A#{r_mm},#{r_mm} 0 0,1 #{@off_x_mm + @d_mm + xe_mm},#{@off_x_mm + @off_y_mm + ye_mm} " fill="none" stroke="black" stroke-width="0.25"/>}
          end

          public
          def render ( )
            vert_delta_y_mm = @r_mm * Math.tan( @alpha / 2 )
            hor_delta_y_mm = @r_mm * Math.sin( @alpha )
            hor_delta_x_mm = @r_mm * ( 1.0 - Math.cos( @alpha ) )
            # reference points A and B
            x_A_mm = x_B_mm = 0.0
            y_A_mm = -@w_mm / 2.0
            y_B_mm = @w_mm / 2.0
            line x_A_mm, y_A_mm + vert_delta_y_mm,  x_B_mm, y_B_mm - vert_delta_y_mm
            # reference points C and D
            x_C_mm = x_D_mm = -@d_mm
            y_C_mm = y_B_mm + @d_mm * Math.tan( @alpha )
            y_D_mm = y_A_mm - @d_mm * Math.tan( @alpha )
            line x_C_mm, y_C_mm + vert_delta_y_mm, x_C_mm, @h_mm - @off_y_mm
            line x_D_mm, y_D_mm - vert_delta_y_mm, x_C_mm, -@off_y_mm
            # slopes
            line x_C_mm + hor_delta_x_mm, y_C_mm + vert_delta_y_mm - hor_delta_y_mm, x_B_mm - hor_delta_x_mm, y_B_mm - vert_delta_y_mm + hor_delta_y_mm
            arc x_C_mm, y_C_mm + vert_delta_y_mm, x_C_mm + hor_delta_x_mm, y_C_mm + vert_delta_y_mm - hor_delta_y_mm, @r_mm
            arc x_B_mm, y_B_mm - vert_delta_y_mm, x_B_mm - hor_delta_x_mm, y_B_mm - vert_delta_y_mm + hor_delta_y_mm, @r_mm
            line x_D_mm + hor_delta_x_mm, y_D_mm - vert_delta_y_mm + hor_delta_y_mm, x_A_mm - hor_delta_x_mm, y_A_mm + vert_delta_y_mm - hor_delta_y_mm
            arc x_A_mm - hor_delta_x_mm, y_A_mm + vert_delta_y_mm - hor_delta_y_mm, x_A_mm, y_A_mm + vert_delta_y_mm, @r_mm
            arc x_D_mm + hor_delta_x_mm, y_D_mm - vert_delta_y_mm + hor_delta_y_mm, x_D_mm, y_D_mm - vert_delta_y_mm, @r_mm
            #export
            @img.close
	    # to have paths use user units (mm)
            return @img.output.sub! '<svg ', '<svg viewBox="0 0 %g %g" ' % [ @d_mm + @off_x_mm, @off_x_mm + @h_mm ]
          end
        end

      end
    end
  end
end

drawer = Io::Creat::Slipstick::Utils::PocketDrawer.new( 10.0, 12.0, 80.0, 20.0, 90 )
puts drawer.render()

