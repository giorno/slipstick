
require_relative 'constants'
require_relative 'scale'

module Io::Creat::Slipstick

  # linear decimal scale
  class LinearScale < Scale

    public
    def set_params ( size )
      @size        = size
      @initialized = true
      @scale       = @w_mainscale_mm / @size
    end

    public
    def render ( )
      last_mm = @start_mm
      for i in 0..@size * 2
        x_mm = @start_mm + ( i * @scale / 2 )
	h_idx = i % 2 == 0 ? 0 : 1
        h_mm = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
	render_tick( x_mm, h_mm, ( i % 2 ) == 0 ? "%d" % ( i / 2 ) : nil )
	delta = last_mm - x_mm
	if i > 0
	  render_fodder( last_mm, x_mm, i - 1, 0.5 )
	end
	last_mm = x_mm
      end
      render_label( )
    end

    # fill the range with smallest ticks
    private
    def render_fodder ( start_mm, end_mm, start_val, step )
      render_fodder_int( calc_fodder( start_mm, end_mm ), end_mm, start_val, step )
    end

    private
    def render_fodder_int ( no_smallest, start_mm, start_val, step )
      if no_smallest > 0
        stepper = step / no_smallest
        for k in 1..no_smallest - 1
          mx = @start_mm + ( start_val * step + k * stepper ) * @scale
          h = @h_mm * ( k % ( no_smallest / 5.0 )  == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][3] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][4] )
          render_tick( mx, h, nil )
        end
      end
    end

  end # LinearScale

  class InchScale < LinearScale

    public
    def set_params ( size )
      super( size )
      @scale = @size * 2.54
    end

    # fill the range with smallest ticks
    private
    def render_fodder ( start_mm, end_mm, start_val, step )
      render_fodder_int( 16, end_mm, start_val, step )
    end

    private
    def render_fodder_int ( no_smallest, start_mm, start_val, step )
      heights = [ 8, 4, 2, 1 ]
      if no_smallest > 0
        stepper = step / no_smallest
        for k in 1..no_smallest - 1
          x_mm = @start_mm + ( start_val * step + k * stepper ) * @scale
          h_idx = 1
          heights.each do | divisor |
            h_idx += 1
            if k % divisor == 0
              break
            end
          end
          h_mm = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
          render_tick( x_mm, h_mm, nil )
        end
      end
    end

  end # InchScale

end # Io::Creat::Slipstick

