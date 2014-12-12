#!/usr/bin/ruby

require 'rasem'

module Io
  module Creat
    module Slipstick
      module Utils

        # draws path for stator element of a slipstick, needed because Inkscape
        # does not support fillet tool in the main/stable codebase yet
        class StatorDrawer
          public
          def initialize ( w_mm, h_mm, r_mm, d_mm, w_pocket_mm, alpha_deg = 90.0, off_y_mm = nil )
            @r_mm = r_mm # arc diameter
            @d_mm = d_mm # horizontal depth
            @h_mm = h_mm # vertical height
            @w_mm = w_mm # width
            @w_pocket_mm = w_pocket_mm # vertical width of pocket
            @off_y_mm = off_y_mm.nil? ? h_mm / 2.0 : off_y_mm # zero point
            @alpha = ( alpha_deg / 2.0 ) * Math::PI / 180 # angle between pocket sides
	    @frame_mm = 10.0
            @img = Rasem::SVGImage.new( "%dmm" % ( @w_mm + @frame_mm ), "%dmm" % ( @frame_mm + @h_mm ) )
            @output = @img.instance_variable_get( :@output )
            @in_path = false
          end

          # begin an SVG path
          protected
          def pbegin ( x_mm = 0.0, y_mm = 0.0 )
            @output << %Q{<path d="}
            @in_path = true
          end

          # close an SVG path and apply the style in the process
          protected
          def pend ( )
            @output << %Q{" fill="none" stroke="black" stroke-width="0.25"/>}
            @in_path = false
          end

          protected
          def assert_in_path ( )
            raise "Attempted drawing in a closed path" unless @in_path == true
          end

          protected
          def move ( x_mm, y_mm )
            assert_in_path
            @output << %Q{M#{@frame_mm / 2 + x_mm},#{@frame_mm / 2 + y_mm} }
          end

          protected
          def line ( x_mm, y_mm )
            assert_in_path
            @output << %Q{L#{@frame_mm / 2 + x_mm},#{@frame_mm / 2 + y_mm} }
          end

          # render line segment using relative coordinates
          protected
          def rline ( x_mm, y_mm )
            assert_in_path
            @output << %Q{l#{x_mm},#{y_mm} }
          end

          protected
          def arc ( x_mm, y_mm, r_mm, dir = "0,1" )
            assert_in_path
            @output << %Q{A#{r_mm},#{r_mm} 0 #{dir} #{@frame_mm / 2 + x_mm},#{@frame_mm / 2 + y_mm} }
          end

          # calculates opposite angle value [rad]
          protected
          def calc_rev_alpha ( alpha )
            raise "Angle must be in range 0..π/2" unless ( alpha >= 0.0 ) and ( alpha <= Math::PI )
            return ( Math::PI / 2 ) - alpha
          end

          # render invagination on a side of the stator
          protected
          def pocket ( off_y_mm, alpha, dir = 1 )
            vert_delta_y_mm = @r_mm * Math.tan( calc_rev_alpha( alpha ) / 2 )
            hor_delta_y_mm = @r_mm * Math.sin( calc_rev_alpha( alpha ) )
            hor_delta_x_mm = @r_mm * ( 1.0 - Math.cos( calc_rev_alpha( alpha ) ) )
            # reference points A and B
            x_CD_mm = dir > 0 ? @w_mm : 0
            x_AB_mm = x_CD_mm - dir * @d_mm
            y_A_mm = off_y_mm + dir * @w_pocket_mm / 2.0
            y_B_mm = off_y_mm - dir * @w_pocket_mm / 2.0
            # reference points C and D
            y_C_mm = y_B_mm - dir * @d_mm * Math.tan( alpha )
            y_D_mm = y_A_mm + dir * @d_mm * Math.tan( alpha )
            # lead in
            line x_CD_mm, y_C_mm - dir * vert_delta_y_mm
            arc x_CD_mm - dir * hor_delta_x_mm, y_C_mm - dir * ( vert_delta_y_mm - hor_delta_y_mm ), @r_mm
            line x_AB_mm + dir * hor_delta_x_mm, y_B_mm + dir * ( vert_delta_y_mm - hor_delta_y_mm )
            # bottom of the pocket
            arc x_AB_mm, y_B_mm + dir * ( vert_delta_y_mm ), @r_mm, "0,0"
            line x_AB_mm, y_A_mm - dir * vert_delta_y_mm
            arc x_AB_mm + dir * hor_delta_x_mm, y_A_mm - dir * ( vert_delta_y_mm - hor_delta_y_mm), @r_mm, "0,0"
            # lead out
            line x_CD_mm - dir * hor_delta_x_mm, y_D_mm + dir * ( vert_delta_y_mm - hor_delta_y_mm )
            arc x_CD_mm, y_D_mm + dir * ( vert_delta_y_mm ), @r_mm
            line x_CD_mm, dir > 0 ? @h_mm : 0
          end

          public
          def render ( )
            pbegin
              move 0, 0
              line @w_mm, 0
              pocket @off_y_mm, @alpha
              line 0, @h_mm
              pocket @off_y_mm, @alpha, -1
              line 0, 0
            pend
            @img.close
	    # to have paths use user units (mm)
            return @img.output.sub! '<svg ', '<svg viewBox="0 0 %g %g" ' % [ @w_mm + @frame_mm, @frame_mm + @h_mm ]
          end
        end

      end
    end
  end
end

drawer = Io::Creat::Slipstick::Utils::StatorDrawer.new( 287.0, 60.0, 4.0, 8.0, 16.0, 60 )
puts drawer.render()

