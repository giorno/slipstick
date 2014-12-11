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
          def initialize ( h_mm, r_mm, d_mm, w_mm, alpha_deg = 90.0, off_y_mm = nil )
            @r_mm = r_mm # arc diameter
            @d_mm = d_mm # horizontal depth
            @h_mm = h_mm # vertical height
            @w_mm = w_mm # wertical width
            @off_y_mm = off_y_mm.nil? ? h_mm / 2.0 : off_y_mm # zero point
            @alpha = ( alpha_deg / 2.0 ) * Math::PI / 180 # angle between pocket sides
	    @frame_mm = 10.0
            @img = Rasem::SVGImage.new( "%dmm" % ( @d_mm + @frame_mm ), "%dmm" % ( @frame_mm + @h_mm ) )
          end

          protected
          def line ( x1_mm, y1_mm, x2_mm, y2_mm )
#	    $stderr.puts( "%g %g %g %g" % [x1_mm, y1_mm, x2_mm, y2_mm] )
            @img.line "%g" % ( @frame_mm / 2 + @d_mm + x1_mm ), "%g" % ( @frame_mm / 2 + @off_y_mm + y1_mm ), "%g" % ( @frame_mm / 2 + @d_mm + x2_mm ), "%g" % ( @frame_mm / 2 + @off_y_mm + y2_mm ), { :stroke => 'black', :stroke_width=>0.25}
          end

          # missing feature in rasem library
          protected
          def arc ( xs_mm, ys_mm, xe_mm, ye_mm, r_mm )
            @img.instance_variable_get( :@output ) << %Q{<path d="M#{@frame_mm / 2 + @d_mm + xs_mm},#{@frame_mm / 2 + @off_y_mm + ys_mm} A#{r_mm},#{r_mm} 0 0,1 #{@frame_mm / 2 + @d_mm + xe_mm},#{@frame_mm / 2 + @off_y_mm + ye_mm} " fill="none" stroke="black" stroke-width="0.25"/>}
          end

          protected
          def calc_rev_alpha ( alpha )
            raise "Angle must be in range 0..π/2" unless ( alpha >= 0.0 ) and ( alpha <= Math::PI )
            return ( Math::PI / 2 ) - alpha
          end

          public
          def render ( )
            vert_delta_y_mm = @r_mm * Math.tan( calc_rev_alpha( @alpha ) / 2 )
            hor_delta_y_mm = @r_mm * Math.sin( calc_rev_alpha( @alpha ) )
            hor_delta_x_mm = @r_mm * ( 1.0 - Math.cos( calc_rev_alpha( @alpha ) ) )
            # reference points A and B
            x_AB_mm = 0.0
            y_A_mm = -@w_mm / 2.0
            y_B_mm = @w_mm / 2.0
            line x_AB_mm, y_A_mm + vert_delta_y_mm,  x_AB_mm, y_B_mm - vert_delta_y_mm
            # reference points C and D
            x_CD_mm = -@d_mm
            y_C_mm = y_B_mm + @d_mm * Math.tan( @alpha )
            y_D_mm = y_A_mm - @d_mm * Math.tan( @alpha )
            line x_CD_mm, y_C_mm + vert_delta_y_mm, x_CD_mm, @h_mm - @off_y_mm
            line x_CD_mm, y_D_mm - vert_delta_y_mm, x_CD_mm, -@off_y_mm
            # slopes
            line x_CD_mm + hor_delta_x_mm, y_C_mm + vert_delta_y_mm - hor_delta_y_mm, x_AB_mm - hor_delta_x_mm, y_B_mm - vert_delta_y_mm + hor_delta_y_mm
            arc x_CD_mm, y_C_mm + vert_delta_y_mm, x_CD_mm + hor_delta_x_mm, y_C_mm + vert_delta_y_mm - hor_delta_y_mm, @r_mm
            arc x_AB_mm, y_B_mm - vert_delta_y_mm, x_AB_mm - hor_delta_x_mm, y_B_mm - vert_delta_y_mm + hor_delta_y_mm, @r_mm
            line x_CD_mm + hor_delta_x_mm, y_D_mm - vert_delta_y_mm + hor_delta_y_mm, x_AB_mm - hor_delta_x_mm, y_A_mm + vert_delta_y_mm - hor_delta_y_mm
            arc x_AB_mm - hor_delta_x_mm, y_A_mm + vert_delta_y_mm - hor_delta_y_mm, x_AB_mm, y_A_mm + vert_delta_y_mm, @r_mm
            arc x_CD_mm + hor_delta_x_mm, y_D_mm - vert_delta_y_mm + hor_delta_y_mm, x_CD_mm, y_D_mm - vert_delta_y_mm, @r_mm
            #export
            @img.close
	    # to have paths use user units (mm)
            return @img.output.sub! '<svg ', '<svg viewBox="0 0 %g %g" ' % [ @d_mm + @frame_mm, @frame_mm + @h_mm ]
          end
        end

      end
    end
  end
end

drawer = Io::Creat::Slipstick::Utils::PocketDrawer.new( 60.0, 6.0, 8.0, 16.0, 60 )
puts drawer.render()

