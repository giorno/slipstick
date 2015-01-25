#!/usr/bin/ruby

require 'rasem'

module Io
  module Creat

    # an adapter, adds various SVG features to Rasem SVGImage
    class Svg < Rasem::SVGImage

      # adds viewBox attribute to the header
      def write_header( width, height )
        @output << <<-HEADER
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="#{width}" height="#{height}" viewBox="0 0 width height" version="1.1"
  xmlns="http://www.w3.org/2000/svg">
        HEADER
        @in_path = false # as good place as any
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
        @output << %Q{" fill="none" stroke="black" stroke-width="0.11"/>}
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

    end
  end
end

