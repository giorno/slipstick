
require_relative 'constants'
require_relative 'scale'
require_relative 'pythag'

module Io::Creat::Slipstick

  # scale of powers, e^x, e^0.x, e^0.0x
  class PowerScale < PythagoreanScale

    public
    def set_params ( values = [ 2.5, 2.6, 2.7, 3.0, 3.5, 4.0, 4.5, 5.0, 6.0, 7.0, 10.0, 50.0, 100.0, 500.0, 1000.0, 5000.0, 10000.0, 30000.0 ] )
      super( values )
    #  @initialized = true
    #  @scale       = @w_mainscale_mm / 1
    #  @values      = values
    #  @dir         = 1
    end

#    public
#    def render ( )
#      last_val = nil
#      last = -1
#      @values.each do | val |
#        x = @start_mm + Math.log10( compute( val ) ) * @scale
#        render_tick( x, @h_mm, "%s\u00a0" % ( "%g" % val )[1..-1] )
#        if not last_val.nil?
#          render_fodder( last, x, last_val, val - last_val, 1 )
#        end
#        last = x
#        last_val = val
#      end
#      render_label( )
#    end

    protected
    def fmt_label( val )
        return "%s" % ( "%g" % val )
    end

    protected
    def compute ( val )
      return Math.log( val )
    end

  end # PowerScale

end # Io::Creat::Slipstick

