
# vim: et

require_relative 'constants'
require_relative 'scale'
require_relative 'log'

module Io::Creat::Slipstick

  class PhotoScale < LogScale

  end # PhotoScale

  # Scale for calculating hyperfocal distance
  # H = f^2 / coc * val
  class HyperfocalDistanceScale < PhotoScale
    VALUES  = [ 1.4, 1.6, 1.8, 2, 2.2, 2.4, 2.8, 3.2, 3.5, 4, 4.5, 5.0, 5.6,
                6.3, 7.1, 8, 9, 10, 11, 13, 14, 16, 18, 20,  22, 25, 29, 32 ]
    SMALL   = [ 1.6, 1.8, 2.2, 2.4, 3.2, 3.5, 4.5, 5, 6.3, 7.1, 9, 10, 13, 14,
                18, 20, 25, 29 ]

    # coc .. circle of confusion
    def set_params ( coc )
      @coc = coc
      super( VALUES, SMALL )
      @scale /= 2
    end

    protected
    def comp ( val )
      return super( 100.0 * @coc * val )
    end

  end # HyperfocalDistanceScale

end # Io::Creat::Slipstick

