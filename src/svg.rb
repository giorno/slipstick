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
<svg viewBox="0 0 #{width} #{height}" width="#{width}mm" height="#{height}mm" version="1.1"
  xmlns="http://www.w3.org/2000/svg">
        HEADER
        @in_path = false # as good place as any
      end

      # begin an SVG path
      public
      def pbegin ( )
        @output << %Q{<path d="}
        @in_path = true
      end

      # close an SVG path and apply the style in the process
      public
      def pend ( style = { "fill" => "none", "stroke" => "black", "stroke-width" => "0.11" } )
        @output << %Q{" }
	write_style(style)
        @output << %Q{/>}
        @in_path = false
      end

      public
      def assert_in_path ( )
        raise "Attempted drawing in a closed path" unless @in_path == true
      end

      public
      def move ( x_mm, y_mm )
        assert_in_path
        @output << %Q{M#{x_mm},#{y_mm} }
      end

      # render line segment using relative coordinates
      public
      def rline ( x_mm, y_mm )
        assert_in_path
        @output << %Q{l#{x_mm},#{y_mm} }
      end

      public
      def arc ( x_mm, y_mm, r_mm, dir = "0,1" )
        assert_in_path
        @output << %Q{A#{r_mm},#{r_mm} 0 #{dir} #{x_mm},#{y_mm} }
      end

    end # Svg

  end #Creat
end # Io

