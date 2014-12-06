
require_relative 'constants'
require_relative 'decimal'
require_relative 'linear'
require_relative 'trigon'

module Io::Creat::Slipstick::ScaleType
  LOG_DECIMAL = 0
  LIN_DECIMAL = 1
  TGN_SIN     = 2
  TGN_TAN     = 3
  TGN_SINTAN  = 4
end

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
    def create_scale ( type, label, rel_off_y_mm = 0, flipped = false )
      case type
        when Io::Creat::Slipstick::ScaleType::LOG_DECIMAL
          return Io::Creat::Slipstick::DecimalScale.new( self, label, 0, rel_off_y_mm, @h_mm, flipped )
        when Io::Creat::Slipstick::ScaleType::LIN_DECIMAL
          return Io::Creat::Slipstick::LinearScale.new( self, label, 0, rel_off_y_mm, @h_mm, flipped )
        when Io::Creat::Slipstick::ScaleType::TGN_SIN
          return Io::Creat::Slipstick::SinScale.new( self, label, 0, rel_off_y_mm, @h_mm, flipped )
        when Io::Creat::Slipstick::ScaleType::TGN_TAN
          return Io::Creat::Slipstick::TanScale.new( self, label, 0, rel_off_y_mm, @h_mm, flipped )
        when Io::Creat::Slipstick::ScaleType::TGN_SINTAN
          return Io::Creat::Slipstick::SinTanScale.new( self, label, 0, rel_off_y_mm, @h_mm, flipped )
        else
          raise "Unrecognized scale type"
      end
    end

    public
    def render()
      h_mm = @h_mm / @children.length # allocate evenly
      off_y_mm = @off_y_mm
      @children.each do | child |
        child.check_initialized( )
        child.instance_variable_set( :@off_y_mm, off_y_mm + ( child.instance_variable_get( :@flipped ) ? h_mm : 0 ) )
        child.instance_variable_set( :@h_mm, h_mm - child.calc_tick_font_height_mm( ) )
        off_y_mm += h_mm
        child.render( )
      end
    end
  end

end # module io::creat::slipstick::layout

