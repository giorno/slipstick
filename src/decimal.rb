
require_relative 'constants'
require_relative 'scale'

module Io::Creat::Slipstick

  # a leaf node
  class DecimalScale < Scale

    public
    def initialize ( parent, label, size, rel_off_x_mm, rel_off_y_mm, h_mm, flipped = false )
      super( parent, label, rel_off_x_mm, rel_off_y_mm, h_mm, flipped )

      @size      = size
      @constants = {}
      @scale     = @w_mainscale_mm / @size
      @start_mm  = @w_label_mm + @w_subscale_mm
    end

    # these constants will be added as explicit ticks with cursive names when render() is called
    # predefined: Euler's number, Pythagoras' number, square root of 2, Fibonacci's number
    public
    def add_constants ( constants = CONST_MATH  )
      @constants = constants
    end

    public
    def render ( )
      last = @start_mm
      for i in 1..@size
        # next tick
        upper = 10 ** i
        step = upper / 20.0
        base = 10 ** ( i - 1 ) 
        for j in 0..18
          value = base + j * step
          # physical dimension coordinates
          x = @start_mm + Math.log10( value ) * @scale
          h = @h_mm * ( j == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][0] : ( j % 2 == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][2] ) )
          if j < 18 # last one is not rendered, but is required for small ticks calculation
           render_tick( x, h, ( j % 2 ) == 0 ? "%d" % value : nil )
          end

          if j > 0
	    render_fodder( last, x, base + ( j - 1 ) * step, step )
          end
          last = x
        end
      end
      # last tick
      render_tick( @start_mm + @w_mainscale_mm, @h_mm, "%d" % ( 10 ** @size ) )

      render_label( )
      render_constants()
      render_subscale()
    end

    private
    def render_constants()
      @constants.each do | name, value |
        x = @start_mm + Math.log10( value ) * @scale
        h = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1]
        render_tick( x, h, "%s" % name, Io::Creat::Slipstick::Entity::CONSTANT )
      end
    end

    # fill the range with smallest ticks
    private
    def render_fodder( start_mm, end_mm, start_val, step )
      delta = ( start_mm.abs - end_mm.abs ).abs
      no_smallest = 0
      @dim[Io::Creat::Slipstick::Key::FODDERS].each do | no |
        if delta > no * @dim[Io::Creat::Slipstick::Key::CLEARING]
          no_smallest = no
          break
        end
      end

      if no_smallest > 0
        stepper = step / no_smallest
        for k in 1..no_smallest - 1
          mx = @start_mm + Math.log10( start_val + k * stepper ) * @scale
          h = @h_mm * ( k % ( no_smallest / 5 )  == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][3] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][4] )
          render_tick( mx, h, nil )
        end
      end
    end

    # fill range given by border with short scale of log() for values under 1 to the left of the 1 tick
    private
    def render_subscale ( )
      if @w_subscale_mm <= 0
        return
      end

      value = 1
      last = @start_mm
      step = 0.02
      while true do
        value -= step
        x = @start_mm + Math.log10( value ) * @scale
        if x <= @w_label_mm
          return
        end
        round = ( value * 20 ).round( 2 ) % 2 == 0
        h = @h_mm * ( round ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][2] )
        render_tick( x, h, ( round ? ( "%.1f" % value )[1..-1] : nil ) )

        render_fodder( last, x, value, 0.02 )
        last = x
      end
    end

  end
end

