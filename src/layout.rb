require 'rasem'

require './hierarchy'
require './decimal'

module Io::Creat::Slipstick::Layout

  # a collection of Scales serving as a sliding strip
  class Strip < Io::Creat::Slipstick::Node
    public
    def initialize ( parent, h_mm, rel_off_x_mm, rel_off_y_mm, w_mainscale_mm, w_label_mm = 0, w_subscale_mm = 0, w_after_mm = 0 )
      super( parent, rel_off_x_mm, rel_off_y_mm )
      @h_mm           = h_mm
      @w_mainscale_mm = w_mainscale_mm
      @w_label_mm     = w_label_mm
      @w_subscale_mm  = w_subscale_mm
      @w_after_mm     = w_after_mm
      # TODO check that sum of widths does not exceed parent's width
    end

    public
    def create_scale ( label, size, rel_off_y_mm = 0, flipped = false  )
      return Io::Creat::Slipstick::DecimalScale.new( self, label, size, 0, rel_off_y_mm, @h_mm, @w_mainscale_mm, @w_label_mm, @w_subscale_mm, @w_after_mm, flipped )
    end
  end

  # a vertical layout of Strips to be printed and cut out
  class Sheet < Io::Creat::Slipstick::Node
    # by default initialized to landscape A4 format with 5mm borders
    public
    def initialize ( w_mm = 297, h_mm = 210, border_x_mm = 5, border_y_mm = nil, spacing_y_mm = nil )
      super( nil, border_x_mm, border_y_mm.nil? ? border_x_mm : border_y_mm )
      @w_mm         = w_mm
      @h_mm         = h_mm
      @border_x_mm  = border_x_mm
      @border_y_mm  = border_y_mm.nil? ? border_x_mm : border_y_mm
      @spacing_y_mm = spacing_y_mm.nil? ? @border_y_mm : spacing_y_mm
      @y_tracker_mm = @border_y_mm
      @img = Rasem::SVGImage.new( "%dmm" % @w_mm, "%dmm" % @h_mm )
    end

    # TODO throw exception when tracker would reach beyond the bottom border
    public
    def create_strip ( h_mm, w_mainscale_mm, w_label_mm = 0, w_subscale_mm = 0, w_after_mm = 0 )
      strip = Strip.new( self, h_mm, @border_x_mm, @y_tracker_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
      @y_tracker_mm += h_mm + @spacing_y_mm
      return strip
    end

    public
    def render()
       super()
       @img.close
       return @img.output
    end
  end
end # module io::creat::slipstick::layout

