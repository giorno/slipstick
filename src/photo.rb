
# vim: et

require_relative 'constants'
require_relative 'scale'
require_relative 'log'

module Io::Creat::Slipstick

  class PhotoScale < LogScale

    # f-stop ~= sqrt( 2 ^ aperture value )
    #
    #           aperture    f-stop
    #           value
    F_STOPS = {  1.0      =>  1.4,
                 1.3      =>  1.6,
                 1.5      =>  1.7,
                 1.7      =>  1.8,

                 2.0      =>  2.0,
                 2.3      =>  2.2,
                 2.5      =>  2.4,
                 2.7      =>  2.5,

                 3.0      =>  2.8,
                 3.3      =>  3.2,
                 3.5      =>  3.3,
                 3.7      =>  3.5,

                 4.0      =>  4.0,
                 4.3      =>  4.5,
                 4.5      =>  4.8,
                 4.7      =>  5.0,

                 5.0      =>  5.6,
                 5.3      =>  6.3,
                 5.5      =>  6.7,
                 5.7      =>  7.1,

                 6.0      =>  8.0,
                 6.3      =>  9.0,
                 6.5      =>  9.5,
                 6.7      => 10.0,

                 7.0      => 11.0,
                 7.3      => 13.0,
                 7.7      => 14.0,

                 8.0      => 16.0,
                 8.3      => 18.0,
                 8.5      => 19.0,
                 8.7      => 20.0,

                 9.0      => 22.0,
                 9.3      => 25.0,
                 9.5      => 27.0,
                 9.7      => 29.0,

                10.0      => 32.0
              }

  end # PhotoScale

  # Scale for calculating hyperfocal distance
  # H = f^2 / coc * val
  class HyperfocalDistanceScale < PhotoScale
    SMALL   = [ 1.3, 1.7, 2.3, 2.7, 3.3, 3.3, 4.3, 4.7, 5.3, 5.7, 6.3, 6.7, 7.3, 7.7,
                8.3, 8.7, 9.3, 9.7 ]
    NO_LABEL = [ 1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 9.5 ]
    def fmt ( val )
      if NO_LABEL.include?( val )
        return nil
      end
      return "%g" % F_STOPS[val]
    end # fmt

    # coc .. circle of confusion
    def set_params ( coc )
      @coc = coc
      super( F_STOPS.keys, SMALL, {}, NO_LABEL )
      @scale /= 2
    end

    protected
    def comp ( val )
      return super( 100.0 * @coc * Math.sqrt( 2 ** val ) )
    end

  end # HyperfocalDistanceScale

end # Io::Creat::Slipstick

