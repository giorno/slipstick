#!/usr/bin/ruby

# vim; et
#
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
  xmlns:xlink="http://www.w3.org/1999/xlink"
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

      # render line with pattern
      public
      def pline( x1, y1, x2, y2, style=DefaultStyles[:line], pattern = nil )
        # fallback
        if pattern.nil?
          line( x1, y1, x2, y2, style )
          return
        end
        @output << %Q{<line stroke-dasharray="#{pattern}" x1="#{x1}" y1="#{y1}" x2="#{x2}" y2="#{y2}"}
        write_style(style)
        @output << %Q{/>}
      end

      # render line segment using relative coordinates
      public
      def rline ( x_mm, y_mm )
        assert_in_path
        @output << %Q{L#{x_mm},#{y_mm} }
      end

      public
      def arc ( x_mm, y_mm, r_mm, dir = "0,1" )
        assert_in_path
        @output << %Q{A#{r_mm},#{r_mm} 0 #{dir} #{x_mm},#{y_mm} }
      end

      # render text rotated around its position coordinates
      public
      def rtext( x, y, deg, text, style )
        @output << %Q{<text x="#{x}" y="#{y}" transform="rotate(#{deg}, #{x}, #{y})"}
        style = fix_style(default_style.merge(style))
        @output << %Q{ font-family="#{style.delete "font-family"}"} if style["font-family"]
        @output << %Q{ font-size="#{style.delete "font-size"}"} if style["font-size"]
        write_style style
        @output << ">"
        dy = 0      # First line should not be shifted
        text.each_line do |line|
          @output << %Q{<tspan x="#{x}" dy="#{dy}em">}
          dy = 1    # Next lines should be shifted
          @output << line.rstrip
          @output << "</tspan>"
        end
        @output << "</text>"
      end

      # embed external SVG at specified position
      public
      def import ( path, x, y, w, h, deg = 0 )
        # hack to bypass Inkscape resistance to accept mm units
        @output << %Q{<use x="#{x}" y="#{y}" width="#{w}" height="#{h*2}" xlink:href="#{path}#layer1" transform="rotate(#{deg}, #{x}, #{y})"/>}
      end

    end # Svg

  end #Creat
end # Io

