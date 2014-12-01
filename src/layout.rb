require 'rasem'

require './decimal'

module Io::Creat::Slipstick::Layout

  # a collection of Scales serving as a sliding strip
  class Strip

    def initialize ( parent, width_mm, height_mm, offset_x_mm, offset_y_mm, scale_height_mm )
      @parent          = parent
      @width_mm        = width_mm
      @height_mm       = height_mm
      @offset_x_mm     = offset_x_mm
      @offset_y_mm     = offset_y_mm
      @scale_height_mm = scale_height_mm
      @scales          = []
    end

    # align_bottom if true, lines are aligned to the bottom
    def create_scale ( label, size, baseline_x_mm = 0, baseline_y_mm = 0, align_bottom = false  )
      scale = Io::Creat::Slipstick::DecimalScale.new( self, label, @width_mm - baseline_x_mm, @scale_height_mm, @offset_x_mm + baseline_x_mm, @offset_y_mm + baseline_y_mm, size, align_bottom )
      @scales << scale
      return scale
    end

    def render ( )
      @scales.each do | scale |
        scale.render()
      end
    end
  end

  # a vertical layout of Strips to be printed and cut out
  class Sheet
    # by default initialized to landscape A4 format with 5mm borders
    def initialize ( width_mm = 297, height_mm = 210, border_x_mm = 5, border_y_mm = nil, spacing_y_mm = nil )
      @width_mm     = width_mm
      @height_mm    = height_mm
      @border_x_mm  = border_x_mm
      @border_y_mm  = border_y_mm.nil? ? border_x_mm : border_y_mm
      @spacing_y_mm = spacing_y_mm.nil? ? @border_y_mm : spacing_y_mm
      @y_tracker_mm = @border_y_mm
      @strips = []

      @img = Rasem::SVGImage.new( "%dmm" % @width_mm, "%dmm" % @height_mm )
    end

    # TODO throw exception when tracker would reach beyond the bottom border
    def create_strip ( height_mm, scale_height_mm, width_mm = nil )
      strip = Strip.new( self,
                         width_mm.nil? ? @width_mm - 2 * @border_x_mm : width_mm,
                         height_mm,
                         @border_x_mm,
                         @y_tracker_mm,
                         scale_height_mm )
      @strips << strip
      @y_tracker_mm += height_mm + @spacing_y_mm
      return strip
    end

    def render ( )
      @strips.each do | strip |
        strip.render( )
      end
      @img.close
      return @img.output
    end
  end
end # module io::creat::slipstick::layout

