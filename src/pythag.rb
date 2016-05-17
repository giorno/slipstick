
# vim: et

require_relative 'scale'

module Io::Creat::Slipstick

  # scale of sqrt( 1 - x^2 )
  class PythagoreanScale < DecimalScale
    public
    def set_params ( values = [ 0.995, 0.99, 0.98, 0.97, 0.96, 0.95, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.0 ] )
      @initialized = true
      @scale       = @w_mainscale_mm / 1
      @values      = values
      @dir         = 1
      @h_idx_off   = 1
    end

    public
    def render ( )
      last_val = nil
      last = -1
      @values.each do | val |
        x = @start_mm + Math.log10( compute( val ) ) * @scale
        render_tick( x, @h_mm, fmt_label( val ) )
        if not last_val.nil?
          render_fodder( last, x, last_val, val - last_val, @h_idx_off )
        end
        last = x
        last_val = val
      end
      render_label( )
    end

    protected
    def fmt_label( val )
      if val == 0.1
        return nil
      elsif val == 0.0
        return "\u00a00"
      else
        return "%s\u00a0" % ( "%g" % val )[1..-1]
      end
    end

    protected
    def compute ( val )
      return 10.0 * Math.sin( Math.acos( val ) )
    end
  end
end

