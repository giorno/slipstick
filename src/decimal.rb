
require_relative 'constants'
require_relative 'scale'

module Io::Creat::Slipstick

  # logarithmic decimal scale
  class DecimalScale < Scale

    public
    def set_params ( size, inverse = false )
      @size = size
      @inverse = inverse # if true, scale runs from the right to the left
      @scale = @w_mainscale_mm / @size
      if @inverse
        @start_mm += @w_mainscale_mm
        @dir = -1
      else
        @dir = 1
      end
      @initialized = true
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
          x = @start_mm + @dir * Math.log10( value ) * @scale
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
      render_tick( @start_mm + @dir * @w_mainscale_mm, @h_mm, "%d" % ( 10 ** @size ) )

      render_label( )
      render_constants()
      render_subscales()
    end

    private
    def render_constants()
      @constants.each do | name, value |
        x = @start_mm + @dir * Math.log10( value ) * @scale
        h = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1]
        render_tick( x, h, "%s" % name, Io::Creat::Slipstick::Entity::CONSTANT )
      end
    end

    # fill the range with smallest ticks
    private
    def render_fodder( start_mm, end_mm, start_val, step )
      no_smallest = calc_fodder( start_mm, end_mm )
      if no_smallest > 0
        stepper = step / no_smallest
        for k in 1..no_smallest - 1
          mx = @start_mm + @dir * Math.log10( start_val + k * stepper ) * @scale
          h = @h_mm * ( k % ( no_smallest / 5 )  == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][3] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][4] )
          render_tick( mx, h, nil )
        end
      end
    end

    # fill range given by border with short scale of log() for values under 1 to the left of the 1 tick
    private
    def render_subscales ( )
               # match flag, start val    start pos                    step                    length
      data = [ [ Io::Creat::Slipstick::Flag::RENDER_SUBSCALE, 1,           @start_mm,                   -0.02,                  @inverse ? @w_after_mm : @w_subscale_mm ], # subscale
               [ Io::Creat::Slipstick::Flag::RENDER_AFTERSCALE, 10 ** @size, @start_mm + @dir * @w_mainscale_mm, 0.1 * ( 10 ** @size ), @inverse ? @w_subscale_mm : @w_after_mm ] ] # afterscale
      data.each do | match, value, start_mm, step, threshold_mm |
        if threshold_mm <= 0 or @flags & match == 0
          next
        end


        last = start_mm
        while true do
          value += step
          x = @start_mm + @dir * Math.log10( value ) * @scale
          if ( x.abs - start_mm ).abs >= threshold_mm
            break
          end
	  
          round = ( value * 20 ).round( 2 ) % 2 == 0
          h = @h_mm * ( round ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][2] )
          render_tick( x, h,  value < 1 ? ( round ? ( "%.1f" % value )[1..-1] : nil ) : nil )

          render_fodder( last, x, value - step, step )
          last = x
        end
      end
    end

  end
end

