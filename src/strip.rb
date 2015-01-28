
require_relative 'constants'
require_relative 'decimal'
require_relative 'linear'
require_relative 'trigon'
require_relative 'pythag'
require_relative 'power'

module Io::Creat::Slipstick::ScaleType
  LOG_DECIMAL = 0
  LIN_DECIMAL = 1
  LIN_INCH    = 2
  TGN_SIN     = 3
  TGN_TAN     = 4
  TGN_SINTAN  = 5
  TGN_PYTHAG  = 6
  LOG_POWER   = 7
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
    def create_scale ( type, label, h_ratio = 1, flipped = false )
      case type
        when Io::Creat::Slipstick::ScaleType::LOG_DECIMAL
          return Io::Creat::Slipstick::DecimalScale.new( self, label, 0, 0, h_ratio, flipped )
        when Io::Creat::Slipstick::ScaleType::LIN_DECIMAL
          return Io::Creat::Slipstick::LinearScale.new( self, label, 0, 0, h_ratio, flipped )
        when Io::Creat::Slipstick::ScaleType::LIN_INCH
          return Io::Creat::Slipstick::InchScale.new( self, label, 0, 0, h_ratio, flipped )
        when Io::Creat::Slipstick::ScaleType::TGN_SIN
          return Io::Creat::Slipstick::SinScale.new( self, label, 0, 0, h_ratio, flipped )
        when Io::Creat::Slipstick::ScaleType::TGN_TAN
          return Io::Creat::Slipstick::TanScale.new( self, label, 0, 0, h_ratio, flipped )
        when Io::Creat::Slipstick::ScaleType::TGN_SINTAN
          return Io::Creat::Slipstick::SinTanScale.new( self, label, 0, 0, h_ratio, flipped )
        when Io::Creat::Slipstick::ScaleType::TGN_PYTHAG
          return Io::Creat::Slipstick::PythagoreanScale.new( self, label, 0, 0, h_ratio, flipped )
        when Io::Creat::Slipstick::ScaleType::LOG_POWER
          return Io::Creat::Slipstick::PowerScale.new( self, label, 0, 0, h_ratio, flipped )
        else
          raise "Unrecognized scale type"
      end
    end

    public
    def render()
      off_y_mm = @off_y_mm
      # calculate height occupied by text
      h_text_mm = 0
      h_ratios = 0
      @children.each do | child |
        h_text_mm += child.calc_tick_font_height_mm( )
        h_ratios += child.instance_variable_get( :@h_ratio )
      end
      hs_mm = ( @h_mm - h_text_mm )
      @children.each do | child |
        # distribute heights according to the ratios
        h_mm = hs_mm * ( child.instance_variable_get( :@h_ratio ) / h_ratios )
        child.check_initialized( )
        h_scale_mm = h_mm + child.calc_tick_font_height_mm( )
        child.instance_variable_set( :@off_y_mm, off_y_mm + ( child.instance_variable_get( :@flipped ) ? h_scale_mm : 0 ) )
        child.instance_variable_set( :@h_mm, h_mm )
        off_y_mm += h_scale_mm
        child.render( )
      end
    end
  end # Strip

end # Io::Creat::Slipstick::Layout

