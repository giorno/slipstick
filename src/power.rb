
require_relative 'constants'
require_relative 'scale'
require_relative 'pythag'

module Io::Creat::Slipstick

  # scale of powers, e^x, e^0.x, e^0.0x
  class PowerScale < PythagoreanScale
    X = [ 2.5, 2.6, 2.7, 3.0, 3.5, 4.0, 4.5, 5.0, 6.0, 7.0, 10.0, 50.0, 100.0, 500.0, 1000.0, 5000.0, 10000.0, 30000.0 ]
    XX = [ 1.1, 1.12, 1.14, 1.16, 1.18, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5, 1.55, 1.6, 1.65, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8 ]
    XXX = [ 1.01, 1.015, 1.02, 1.025, 1.03, 1.035, 1.04, 1.045, 1.05, 1.06, 1.07, 1.08, 1.09, 1.1, 1.11 ]

    public
    def set_params ( mult = 1, values = X )
      super( values )
      @mult = mult # multiplier applied to value calculation, 1 for e^x, 10 for e^0.x
    end

    protected
    def fmt_label( val )
        return "%s" % ( "%g" % val )
    end

    protected
    def compute ( val )
      return @mult * Math.log( val )
    end

  end # PowerScale

end # Io::Creat::Slipstick

