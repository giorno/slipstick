
require_relative 'scale'

module Io::Creat::Slipstick

  # trigonometric scales are aligned to single sized decimal scales (1-10)
  class TrigonometricScale < Scale
    MAX_LOOPS = 100

    public
    def set_params ( upper_deg, lower_deg, steps_deg, clear_mm = 5 )
      # ranges and stepping specified in degrees
      @upper_deg   = upper_deg
      @lower_deg   = lower_deg
      @steps_deg   = steps_deg
      @clear_mm    = clear_mm
      @scale       = @w_mainscale_mm / 1
      @initialized = true
      @precision   = 10
                 # dist    total ticks        grouping
      @fodders = { 1  => [ [ 12.0, 6.0 ],     [ 2, 6 ] ],
                   5  => [ [ 30.0, 15.0, 5 ], [ 5, 10, 1 ] ],
                   10 => [ [ 20.0 ],          [ 2, 10 ] ],
                   20 => [ [ 10.0 ],          [ 2, 10 ] ] }
    end

    # x position calculation function, must be overriden in the subclasses
    protected
    def compute ( deg )
      raise "Not implemented"
    end

    protected
    def fmt_label ( val )
      return [ val % 10 == 0 ? Io::Creat::Slipstick::Entity::TICK : Io::Creat::Slipstick::Entity::LOTICK, "%d°" % val ]
    end

    public
    def render ( )
      deg = @upper_deg
      last = @start_mm + Math.log10( compute( @upper_deg ) * @precision ) * @scale
      # rightmost tick
      render_tick( last, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][0], "%d°" % deg )
      i = 0
      while i < MAX_LOOPS and deg > @lower_deg do
        i += 1
        @steps_deg.each do | step |
          try_deg = deg - step
          x = @start_mm + Math.log10( compute( try_deg ) * @precision ) * @scale
          delta_mm = last - x
          if delta_mm.abs >= @clear_mm
            delta_deg = deg - try_deg
            h_idx = ( ( @precision * try_deg ) % 100 == 0 ) ? 0 : ( ( ( @precision * try_deg ) % 50 == 0 ) ? 1 : 2 )
            h_mm = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
            style, label = fmt_label( try_deg )
            render_tick( x, h_mm, label, style )
            if last > @lower_deg
              @fodders.each do | match, rules |
                if ( delta_deg - match ).abs < 0.00005
                  rules[0].each do | fodders |
                    if delta_mm / fodders < @dim[Io::Creat::Slipstick::Key::CLEARING]
                      next
                    end
                    fstep_deg = step / fodders
                    for i in 1..fodders - 1
                      fh_idx = ( match - @steps_deg[0] ).abs < 0.00005 ? 2 : 1
                      fh_idx += ( ( i % ( fodders / rules[1][0] ) == 0 ) ? 1 : ( i % ( fodders / rules[1][1] ) == 0 ? 2 : 3 ) )
                      fx_mm = @start_mm + Math.log10( compute( try_deg + i * fstep_deg ) * @precision ) * @scale
                      render_tick( fx_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][fh_idx] )
                    end
                  end
                end
              end
            end
            last = x
            deg = try_deg
            break
          end
        end
      end
      render_label( )
    end
  end

  class SinScale < TrigonometricScale
    protected
    def compute ( deg )
      return Math.sin( Math::PI * deg / 180 )
    end
  end

  class TanScale < TrigonometricScale
    protected
    def compute ( deg )
      return Math.tan( Math::PI * deg / 180 )
    end
  end

  # interpolates sin and tan for small degrees
  class SinTanScale < TrigonometricScale
    public
    def set_params ( upper_deg, lower_deg, steps_deg, clear_mm = 5 )
      super( upper_deg, lower_deg, steps_deg, clear_mm )
      @precision   = 100
                 # dist    total ticks     grouping
      @fodders = { 1.0/12.0  => [ [ 10.0 ],  [ 5, 10 ] ],
                   0.5  => [ [ 30.0, 15.0 ], [ 3, 6 ] ],
                   10 => [ [ 20.0],        [ 2, 10 ] ],
                   20 => [ [ 10.0],        [ 2, 10 ] ] }
    end

    protected
    def fmt_label ( val )
      label = "%g°" % val
      if val < 1.0
        label = "%d'" % ( val * 60 ).round( 1 )
      elsif ( val * 10 ) % 10 != 0
        label = "%d°%d'" % [ val, 6 * ( val * 10 % 10 ) ]
      end
      return [ ( 10 * val ) % 10 == 0 ? Io::Creat::Slipstick::Entity::TICK : Io::Creat::Slipstick::Entity::LOTICK, label ]
    end

    protected
    def compute ( deg )
      return ( Math.tan( Math::PI * deg / 180 ) + Math.sin( Math::PI * deg / 180 ) ) / 2
    end
  end

end

