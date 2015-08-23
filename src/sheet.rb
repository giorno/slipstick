
require_relative 'constants'
require_relative 'strip'
require_relative '../svg/src/svg'

module Io::Creat::Slipstick::Layout

  class Caption < Io::Creat::Slipstick::Node
    public
    def initialize ( parent, rel_off_x_mm, rel_off_y_mm, label )
      super( parent, rel_off_x_mm, rel_off_y_mm )
      @label = label
    end

    public
    def render ( )
        @img.text( "%f" % @off_x_mm,
                   "%f" % ( @off_y_mm + @style[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_SIZE] ),
                   "%s" % @label,
                   { "fill" => @style[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_COLOR],
                     "font-size" => "%f" % @style[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_SIZE],
                     "font-family" => @style[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_FAMILY],
                     "font-style" => @style[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_STYLE],
                     "text-anchor" => "left",
                     #"dominant-baseline" => "hanging", # seems to be ignored by viewers
                     "font-weight" => @style[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_WEIGHT] } )
      
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
      @spacing_y_mm = spacing_y_mm.nil? ? @off_y_mm : spacing_y_mm
      @y_tracker_mm = @off_y_mm
      @img = Io::Creat::Svg.new( "%d" % @w_mm, "%d" % @h_mm )
    end

    # TODO throw exception when tracker would reach beyond the bottom border
    public
    def create_strip ( h_mm, w_mainscale_mm, w_label_mm = 0, w_subscale_mm = 0, w_after_mm = 0 )
      raise "Strip widths exceed the space reserved for them in the Sheet" unless ( w_mainscale_mm + w_label_mm + w_subscale_mm + w_after_mm ) <= @w_mm
      strip = Strip.new( self, h_mm, 0, @y_tracker_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
      @y_tracker_mm += h_mm + @spacing_y_mm
      return strip
    end

    public
    def create_label ( label )
      caption = Caption.new( self, 0, @y_tracker_mm, label )
      @y_tracker_mm += caption.instance_variable_get( :@style )[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_SIZE] + @spacing_y_mm
      return caption
    end

    public
    def render( no_return = false)
       super()
       if not no_return
         @img.close
         return @img.output
       end
    end
  end
end # module io::creat::slipstick::layout

