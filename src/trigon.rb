
require_relative 'scale'

module Io::Creat::Slipstick

  # trigonometric scales are aligned to single sized decimal scales (1-10)
  class TrigonometricScale < Scale
    public
    def set_params ( upper_deg, lower_deg, steps_deg, clear_mm = 5 )
      # ranges and stepping specified in degrees
      @upper_deg   = upper_deg
      @lower_deg   = lower_deg
      @steps_deg   = steps_deg
      @clear_mm    = clear_mm
      @scale       = @w_mainscale_mm / 1
      @initialized = true
    end

    # x position calculation function, must be overriden in the subclasses
    protected
    def compute ( deg )
      raise "Not implemented"
    end

    public
    def render ( )
      deg = @upper_deg
      last = @start_mm + @w_mainscale_mm
      # rightmost tick
      render_tick( last, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][0], "%d" % deg )
      while deg > @lower_deg do
        @steps_deg.each do | step |
          try_deg = deg - step
          x = @start_mm + Math.log10( compute( try_deg ) * 10 ) * @scale
          delta_mm = last - x
          if delta_mm >= @clear_mm
            h_idx = ( try_deg % 10 == 0 ) ? 0 : ( ( try_deg % 5 == 0 ) ? 1 : 2 )
            h_mm = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
            render_tick( x, h_mm, "%d" % try_deg )
            delta_deg = deg - try_deg
            $stderr.puts delta_deg
            if last > @lower_deg
              if delta_deg == 1
                [ 12.0, 6.0 ].each do | fodders |
                  if delta_mm / fodders < @dim[Io::Creat::Slipstick::Key::CLEARING]
                    next
                  end
                  fstep_deg = step / fodders
                  for i in 1..fodders - 1
                    fh_idx = 2 + ( ( i % ( fodders / 2 )  == 0 ) ? 1 : ( i % ( fodders / 6 ) == 0 ? 2 : 3 ) )
                    fx_mm = @start_mm + Math.log10( compute( try_deg + i * fstep_deg ) * 10 ) * @scale
                    render_tick( fx_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][fh_idx] )
                  end
                end
              elsif delta_deg == 5
                [ 30.0, 15.0 ].each do | fodders |
                  if delta_mm / fodders < @dim[Io::Creat::Slipstick::Key::CLEARING]
                    next
                  end
                  fstep_deg = step / fodders
                  for i in 1..fodders - 1
                    fh_idx = 1 + ( ( i % ( fodders / 5 )  == 0 ) ? 1 : ( i % ( fodders / 10 ) == 0 ? 2 : 3 ) )
                    fx_mm = @start_mm + Math.log10( compute( try_deg + i * fstep_deg ) * 10 ) * @scale
                    render_tick( fx_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][fh_idx] )
                  end
                end
              elsif delta_deg == 10
                [ 20.0 ].each do | fodders |
                  if delta_mm / fodders < @dim[Io::Creat::Slipstick::Key::CLEARING]
                    next
                  end
                  fstep_deg = step / fodders
                  for i in 1..fodders - 1
                    fh_idx = 1 + ( ( i % ( fodders / 2 )  == 0 ) ? 1 : ( i % ( fodders / 10 ) == 0 ? 2 : 3 ) )
                    fx_mm = @start_mm + Math.log10( compute( try_deg + i * fstep_deg ) * 10 ) * @scale
                    render_tick( fx_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][fh_idx] )
                  end
                end
              elsif delta_deg == 20
                [ 10.0 ].each do | fodders |
                  if delta_mm / fodders < @dim[Io::Creat::Slipstick::Key::CLEARING]
                    next
                  end
                  fstep_deg = step / fodders
                  for i in 1..fodders - 1
                    fh_idx = 1 + ( ( i % ( fodders / 2 )  == 0 ) ? 1 : ( i % ( fodders / 10 ) == 0 ? 2 : 3 ) )
                    fx_mm = @start_mm + Math.log10( compute( try_deg + i * fstep_deg ) * 10 ) * @scale
                    render_tick( fx_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][fh_idx] )
                  end
                end
              end
            end
            #render_fodder( last, x, deg, -step, h_idx + 1 )
            last = x
            deg = try_deg
            break
          end
        end
      end
      render_label( )
    end

    # fill the range with smallest ticks
    private
    def render_fodder( start_mm, end_mm, start_val, step, h_off_idx )
      no_smallest = calc_fodder( start_mm, end_mm )
      if no_smallest > 0
        stepper = step / no_smallest
        for k in 1..no_smallest - 1
          mx = @start_mm + Math.log10( compute( start_val + k * stepper ) * 10 ) * @scale
          h = @h_mm * ( k % ( no_smallest / 5 )  == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_off_idx] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_off_idx + 1] )
          render_tick( mx, h, nil )
        end
      end
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

end

