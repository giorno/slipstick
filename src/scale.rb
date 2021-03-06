
# vim: et

require_relative 'constants'
require_relative 'node'
require_relative '../svg/src/style'

module Io::Creat::Slipstick

  class Scale < Node
    public
    def initialize ( parent, label, rel_off_x_mm, rel_off_y_mm, h_ratio, flipped = false )
      super( parent, rel_off_x_mm, rel_off_y_mm )
      @label          = label
      @h_ratio        = h_ratio
      @h_mm           = 0.0
      # copy widths from the parent
      @w_mainscale_mm = @parent.instance_variable_get( :@w_mainscale_mm )
      @w_label_mm     = @parent.instance_variable_get( :@w_label_mm )
      @w_subscale_mm  = @parent.instance_variable_get( :@w_subscale_mm )
      @w_after_mm     = @parent.instance_variable_get( :@w_after_mm )
      @start_mm       = @w_label_mm + @w_subscale_mm
      @constants      = {}
      @flipped        = flipped
      @flags          = Io::Creat::Slipstick::Flag::RENDER_SUBSCALE | Io::Creat::Slipstick::Flag::RENDER_AFTERSCALE
      @initialized    = false
    end

    public
    def set_flags ( flags )
      @flags = flags
    end

    public
    def set_overflow ( overflow_mm )
      @dim = @dim.merge( Io::Creat::Slipstick::Key::TICK_OVERFLOW => overflow_mm )
    end

    # used by Strip to check that all parameters were given to the scale
    public
    def check_initialized ( )
      raise "Scale type specific parameters not initialized" unless @initialized
    end

    # these constants will be added as explicit ticks with cursive names when render() is called
    # predefined: Euler's number, Pythagoras' number, square root of 2, Fibonacci's number
    public
    def add_constants ( constants = CONST_MATH  )
      @constants = constants
    end

    public
    def calc_tick_font_height_mm ( )
      return @style[Io::Creat::Slipstick::Entity::TICK][:"font-size"]
    end

    protected
    def calc_fodder ( start_mm, end_mm )
      delta = ( start_mm.abs - end_mm.abs ).abs
      @dim[Io::Creat::Slipstick::Key::FODDERS].each do | no, heights |
        if delta > no * @dim[Io::Creat::Slipstick::Key::CLEARING]
          return no
        end
      end
      return 0
    end

    protected
    def render_label ( )
      if not @label.nil? and @w_label_mm > 0
        font_size_mm = @style[Io::Creat::Slipstick::Entity::LABEL][:"font-size"]
        dy_mm = ( @flipped ? -@h_mm : @h_mm ) / 2
        @img._text( "%f" % ( @off_x_mm + @dim[Io::Creat::Slipstick::Key::CLEARING] ),
                   "%f" % ( @off_y_mm + dy_mm + ( @flipped ? @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] : @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] ) * font_size_mm ),
                   "\u00a0\u00a0%s" % @label,
                   Io::Creat::svg_dec_style_units( @style[Io::Creat::Slipstick::Entity::LABEL], Io::Creat::SVG_STYLE_TEXT ) )
      end
    end

    # draws a vertical line with the current line style and optionally adds
    # a label to it
    protected
    def render_tick ( x_mm, h_mm, label = nil, style = Io::Creat::Slipstick::Entity::TICK )
      flip = @flipped ? -1 : 1
      @img.line( "%f" % ( @off_x_mm + x_mm ),
                 "%f" % ( @off_y_mm - flip * ( style == Io::Creat::Slipstick::Entity::CONSTANT ? -@dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][3] * h_mm : @dim[Io::Creat::Slipstick::Key::TICK_OVERFLOW] ) ),
                 "%f" % ( @off_x_mm + x_mm ),
                 "%f" % ( @off_y_mm + flip * h_mm ),
                 Io::Creat::svg_dec_style_units( @style[style].merge( { :"stroke-linecap" => 'butt' } ) ) )
      render_tick_label( x_mm, h_mm, label, style )
    end

    protected
    def render_tick_label ( x_mm, h_mm, label = nil, style = Io::Creat::Slipstick::Entity::TICK )
      if not label.nil?
        flip = @flipped ? -1 : 1
        font_size_mm = @style[style][:"font-size"]
        @img._text( "%f" % ( @off_x_mm + x_mm + ( style == Io::Creat::Slipstick::Entity::CONSTANT ? -font_size_mm * 0.05 : 0 ) ),
                   "%f" % ( flip * h_mm + @off_y_mm + ( @flipped ? @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] : @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] ) * font_size_mm ), # compensation for ignored (by viewers) vertical alignments
                   "%s" % label,
                   Io::Creat::svg_dec_style_units( @style[style].merge( { :"text-anchor" => 'middle' } ), Io::Creat::SVG_STYLE_TEXT ) )
      end
    end 

  end # Scale
end # Io::Creat::Slipstick

