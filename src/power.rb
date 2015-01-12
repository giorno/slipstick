
require_relative 'constants'
require_relative 'scale'
require_relative 'log'

module Io::Creat::Slipstick

  class PowerScale < LogScale

    public
    def set_params ( mult = 1 )
      case mult
        when 1
          super( PowerXScale::VALUES, PowerXScale::SMALL, PowerXScale::FODDERS, PowerXScale::NOLABEL )
        when 10
          super( Power0XScale::VALUES, [], Power0XScale::FODDERS, [] )
        when 100
          super( Power00XScale::VALUES, [], Power00XScale::FODDERS, [] )
        else
          raise "Unsupported scale multiplier %d" % d
      end
      @mult = mult
    end

    protected
    def comp ( val )
      return @mult * Math.log( val )
    end

    protected
    def fmt ( val )
      if @nolabel.include?( val )
        return nil
      end
      # a power of ten?
      exp = Math.log10( val )
      if val > 100 and exp % 1 == 0
        return "\u00a0%dK" % ( val / 1000 )
      else
        text = super( val )
        if val > 100 and val % 10 == 0
          return text[0]
        elsif text.length > 3
          indent = ''
          for i in 1 .. text.length - 3
            indent += "\u00a0"
          end
          return indent + text
        else
          return @mult == 1 ? text.gsub( '.', '') : text
        end
      end
    end

  end # PowerScale

  # e^x
  class PowerXScale < PowerScale
    VALUES = [     2.5,     2.6,     2.7,    2.8,    2.9,    3.0,    3.5,    4.0,   4.5,     5.0, 6.0, 7.0, 8.0, 9.0,
                  10.0,    15.0,    20.0,   25.0,   30.0,   40.0,   50.0,
                 100.0,   150.0,   200.0,  300.0,  400.0,  500.0,  600.0,  700.0,  800.0,  900.0,
                1000.0,  1500.0,  2000.0, 3000.0, 4000.0, 5000.0, 6000.0, 7000.0, 8000.0, 9000.0,
               10000.0, 20000.0, 30000.0 ]
    FODDERS = {   2.5 => [ 5,  [ 6 ] ],
                  3.0 => [ 10, [ 2 ] ],
                  5.0 => [ 10, [ 5 ] ],
                 10.0 => [ 10, [ 2 ] ],
                 30.0 => [ 10, [ 5 ] ],
                 50.0 => [ 25, [ 5 ] ],
                100.0 => [ 10, [ 2 ] ],
                200.0 => [ 10, [ 5 ] ],
                400.0 => [ 5,  [ 6 ] ],
                700.0 => [ 2,  [ 1 ] ],
               1000.0 => [ 10, [ 5 ] ],
               3000.0 => [ 5,  [ 6 ] ],
               5000.0 => [ 2,  [ 1 ] ],
              10000.0 => [ 10, [ 2 ] ],
              20000.0 => [ 5,  [ 5 ] ], }
    SMALL = [ 2.5, 2.6, 2.7, 2.8, 2.9, 3.5, 4.5, 150.0, 600.0, 700.0, 800.0, 900.0, 1500.0 ]
    NOLABEL = [ 150.0, 600.0, 700.0, 800.0, 900.0, 1500.0, 6000.0, 7000.0, 8000.0, 9000.0 ]
  end # PowerXScale

  # e^0.x
  class Power0XScale < PowerScale
    VALUES = [ 1.1, 1.12, 1.14, 1.16, 1.18, 1.2, 1.25, 1.3, 1.35, 1.4, 1.45, 1.5, 1.55, 1.6, 1.65, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8 ]
    FODDERS = { 1.1 => [ 20,  [ 10, 5 ] ],
                1.2 => [ 10, [ 2 ] ],
                1.7 => [ 10, [ 5 ] ],
                2.0 => [ 5, [ 6 ] ], }
  end # Power0XScale

  # e^0.0x
  class Power00XScale < PowerScale
    VALUES = [ 1.01, 1.015, 1.02, 1.025, 1.03, 1.035, 1.04, 1.045, 1.05, 1.06, 1.07, 1.08, 1.09, 1.1, 1.11 ]
    FODDERS = {   1.01 => [ 50,  [ 10, 5 ] ],
                  1.02 => [ 25, [ 5 ] ],
                  1.05 => [ 20, [ 10, 2 ] ],
                  1.1 => [ 10, [ 5 ] ], }
  end # Power00XScale

end # Io::Creat::Slipstick

