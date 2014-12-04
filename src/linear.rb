
require_relative 'constants'
require_relative 'scale'

module Io::Creat::Slipstick

  # linear decimal scale
  class LinearScale < Scale

    public
    def initialize ( parent, label, size, rel_off_x_mm, rel_off_y_mm, h_mm, flipped = false )
      super( parent, label, rel_off_x_mm, rel_off_y_mm, h_mm, flipped )

      @size      = size
      @constants = {}
      @scale     = @w_mainscale_mm / @size
      @start_mm  = @w_label_mm + @w_subscale_mm
    end

    public
    def render ( )
      last = @start_mm
      for i in 0..@size * 2
        x = @start_mm + ( i * @scale / 2 )
        h = @h_mm * ( i % 2 == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][0] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1] )
	render_tick( x, h, ( i % 2 ) == 0 ? "%d" % ( i / 2 ) : nil )
	delta = last - x
	if i > 0
	  render_fodder( last, x, i - 1, 0.5 )
	end
	last = x
      end
      render_label( )
    end

    # fill the range with smallest ticks
    private
    def render_fodder( start_mm, end_mm, start_val, step )
      no_smallest = calc_fodder( start_mm, end_mm )
      if no_smallest > 0
        stepper = step / no_smallest
        for k in 1..no_smallest - 1
          mx = @start_mm + ( start_val * step + k * stepper ) * @scale
          h = @h_mm * ( k % ( no_smallest / 5 )  == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][3] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][4] )
          render_tick( mx, h, nil )
        end
      end
    end

  end
end

