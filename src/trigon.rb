
# vim: et

require_relative 'scale'

module Io::Creat::Slipstick

  # trigonometric scales are aligned to single sized decimal scales (1-10)
  class TrigonometricScale < Scale
    MAX_LOOPS = 100
    def set_params ( upper_deg, lower_deg, steps_deg, clear_mm = 5 )
      # ranges and stepping specified in degrees
      @upper_deg   = upper_deg
      @lower_deg   = lower_deg
      @steps_deg   = steps_deg
      @clear_mm    = clear_mm
      @scale       = @w_mainscale_mm / 1
      @initialized = true
      @precision   = 10

      @fodders     = { 90 => 5, 80 => 10, 70 => 20, 60 => 10, 40 => 15, 20 => 6, 10 => 12 }
    end

    protected
    def get_fodders ( )
      return { 12 => [ 2, 6 ],
                6 => [ 2, 2 ],
               30 => [ 5, 10, 1 ],
               15 => [ 5, 1 ],
                5 => [ 1, 1 ],
               20 => [ 2, 10 ],
               10 => [ 5, 1 ],
                8 => [ 2, 8 ], }
    end

    # x position calculation function, must be overriden in the subclasses
    protected
    def compute ( deg )
      raise "Not implemented"
    end

    protected
    def fmt_label ( val )
      if val == 80
        return [ Io::Creat::Slipstick::Entity::TICK, "80°\u00a0" ]
      elsif val == 90
        return [ Io::Creat::Slipstick::Entity::TICK, "\u00a0\u00a0\u00a090°" ]
      else
        return [ val % 10 == 0 ? Io::Creat::Slipstick::Entity::TICK : Io::Creat::Slipstick::Entity::LOTICK, "\u00a0%d°" % val ]
      end
    end

    public
    def render ( )
      deg = @upper_deg
      last = @start_mm + Math.log10( compute( @upper_deg ) * @precision ) * @scale
      # rightmost tick
      render_tick( last, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][0], fmt_label( deg )[1] )
      i = 0
      while i < MAX_LOOPS and deg > @lower_deg do
        i += 1
        @steps_deg.each do | step |
          try_deg = deg - step
          x = @start_mm + Math.log10( compute( try_deg ) * @precision ) * @scale
          delta_mm = last - x
          if delta_mm.abs >= @clear_mm or try_deg.round() == 80
            delta_deg = deg - try_deg
            h_idx = ( ( @precision * try_deg ) % 100 == 0 ) ? 0 : ( ( ( @precision * try_deg ) % 50 == 0 ) ? 1 : 2 )
            h_mm = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
            style, label = fmt_label( try_deg )
            render_tick( x, h_mm, label, style )
            # fodders
            no_smallest = 0
            match = 0
            @fodders.each do | threshold, fodders |
              if try_deg < threshold
                no_smallest = fodders
                match = threshold
              end
            end
            if no_smallest > 0 and last > @lower_deg
              rules = get_fodders( )[no_smallest]
              fstep_deg = step * 1.0 / no_smallest
              for i in 1..no_smallest - 1
                fh_idx = ( match - @steps_deg[0] ).abs < 0.00005 ? 2 : 1
                fh_idx += ( ( i % ( no_smallest / rules[0] ) == 0 ) ? 1 : ( i % ( no_smallest / rules[1] ) == 0 ? 2 : 3 ) )
                fx_mm = @start_mm + Math.log10( compute( try_deg + i * fstep_deg ) * @precision ) * @scale
                render_tick( fx_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][fh_idx] )
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

    public
    def render ( )
      @fodders = { 90 => 8, 70 => 20, 60 => 10, 45 => 30, 25 => 6, 20 => 6, 10 => 12 }
      super()
    end
  end

  # interpolates sin and tan for small degrees
  class SinTanScale < TrigonometricScale
    public
    def set_params ( upper_deg, lower_deg, steps_deg, clear_mm = 5 )
      super( upper_deg, lower_deg, steps_deg, clear_mm )
      @precision   = 100
      @fodders     = { 6 => 6, 5 => 15, 3 => 30, 1 => 10 }
    end

    protected
    def get_fodders ( )
      return {
                6 => [ 3, 2 ],
               30 => [ 3, 6, 1 ],
               15 => [ 3, 1 ],
               10 => [ 5, 1 ], }
    end

    protected
    def fmt_label ( val )
      label = "\u00a0%g°" % val
      if val < 1.0 # minutes resolution
        label = "\u00a0%d'" % ( val * 60 ).round( 1 )
      elsif ( val * 10 ) % 10 != 0 # hald-degrees resolution
        label = "\u00a0\u00a0\u00a0\u00a0%d°%d'" % [ val, 6 * ( val * 10 % 10 ) ]
      elsif val == 6 # special case to indent
        label = "%g°\u00a0" % val
      end
      return [ ( 10 * val ) % 10 == 0 ? Io::Creat::Slipstick::Entity::TICK : Io::Creat::Slipstick::Entity::LOTICK, label ]
    end

    protected
    def compute ( deg )
      return ( Math.tan( Math::PI * deg / 180 ) + Math.sin( Math::PI * deg / 180 ) ) / 2
    end
  end

end

