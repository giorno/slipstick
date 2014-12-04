
require_relative 'constants'
require_relative 'node'

module Io::Creat::Slipstick

  class Scale < Node
    public
    def initialize ( parent, label, rel_off_x_mm, rel_off_y_mm, h_mm, flipped = false )
      super( parent, rel_off_x_mm, rel_off_y_mm )
      @label          = label
      @h_mm           = h_mm
      # copy widths from the parent
      @w_mainscale_mm = @parent.instance_variable_get( :@w_mainscale_mm )
      @w_label_mm     = @parent.instance_variable_get( :@w_label_mm )
      @w_subscale_mm  = @parent.instance_variable_get( :@w_subscale_mm )
      @w_after_mm     = @parent.instance_variable_get( :@w_after_mm )
      @flipped        = flipped
      @flags          = Io::Creat::Slipstick::Flag::RENDER_SUBSCALE | Io::Creat::Slipstick::Flag::RENDER_AFTERSCALE
    end

    def set_flags ( flags )
      @flags = flags
    end

    def calc_tick_font_height_mm ( )
      return @style[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_SIZE] * 1.3
    end

    def render_label ( )
      if not @label.nil? and @w_label_mm > 0
        font_size_mm = @style[Io::Creat::Slipstick::Entity::SCALE][Io::Creat::Slipstick::Key::FONT_SIZE]
        @img.text( "%fmm" % ( @off_x_mm + @w_label_mm / 2),
                   "%fmm" % ( @off_y_mm + ( @flipped ? @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] : @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] ) * font_size_mm ),
                   "%s" % @label,
                   { "fill" => @style[Io::Creat::Slipstick::Entity::SCALE][Io::Creat::Slipstick::Key::FONT_COLOR],
                     "font-size" => "%fmm" % font_size_mm,
                     "font-family" => @style[Io::Creat::Slipstick::Entity::SCALE][Io::Creat::Slipstick::Key::FONT_FAMILY],
                     "text-anchor" => "middle",
                     "font-weight" => @style[Io::Creat::Slipstick::Entity::SCALE][Io::Creat::Slipstick::Key::FONT_WEIGHT] } )
      end
    end

    # draws a vertical line with the current line style and optionally adds
    # a label to it
    protected
    def render_tick ( x_mm, h_mm, label = nil, style = Io::Creat::Slipstick::Entity::TICK )
      flip = @flipped ? -1 : 1
      @img.line( "%fmm" % ( @off_x_mm + x_mm ),
                 "%fmm" % ( @off_y_mm - flip * ( style == Io::Creat::Slipstick::Entity::CONSTANT ? -@dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][2] * h_mm : @dim[Io::Creat::Slipstick::Key::CLEARING] ) ),
                 "%fmm" % ( @off_x_mm + x_mm ),
                 "%fmm" % ( @off_y_mm + flip * h_mm ),
                 { "stroke" => @style[style][Io::Creat::Slipstick::Key::LINE_COLOR],
                   "stroke-width" => "%fmm" % @style[style][Io::Creat::Slipstick::Key::LINE_WIDTH],
                   "stroke-linecap" => "square" } )
      if not label.nil?
        font_size_mm = @style[style][Io::Creat::Slipstick::Key::FONT_SIZE]
        @img.text( "%fmm" % ( @off_x_mm + x_mm ),
                   "%fmm" % ( flip * h_mm + @off_y_mm + ( @flipped ? @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] : @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] ) * font_size_mm ), # compensation for ignored (by viewers) vertical alignments
                   "%s" % label,
                   { "fill" => @style[style][Io::Creat::Slipstick::Key::FONT_COLOR],
                     "font-size" => "%fmm" % font_size_mm,
                     "font-family" => @style[style][Io::Creat::Slipstick::Key::FONT_FAMILY],
                     "font-style" => @style[style][Io::Creat::Slipstick::Key::FONT_STYLE],
                     "text-anchor" => "middle",
                     "dominant-baseline" => "hanging", # seems to be ignored by viewers
                     "font-weight" => @style[style][Io::Creat::Slipstick::Key::FONT_WEIGHT] } )
      end
    end
  end

end

