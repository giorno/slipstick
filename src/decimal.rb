
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
      # by default values between 1 and 2 in single range scale are labeled
      if @size == 1
        add_extra_labels( [ 1.1, 1.2, 1.3, 1.5, 1.7, 1.8, 1.9 ] )
      end
      @initialized = true
    end

    public
    def add_constants ( constants = CONST_MATH  )
      @constants = constants
    end

    # adds values that will be rendered regardless their cardinality
    # in the scale
    public
    def add_extra_labels ( labels = [] )
      @extra_labels = labels
    end

    protected
    def is_extra_label ( value )
      return instance_variable_defined?( :@extra_labels ) && @extra_labels.include?( value )
    end

    public
    def set_overflow ( overflow_mm )
      @dim = @dim.merge( Io::Creat::Slipstick::Key::TICK_OVERFLOW => overflow_mm )
    end

    protected
    def compute ( val )
      return val
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
          h_idx = ( j == 0 ? 0 : ( j % 2 == 0 ? 1 : 2 ) )
          h = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
          if j < 18 # last one is not rendered, but is required for small ticks calculation
            render_tick( x, h, ( j % 2 == 0 or is_extra_label( value ) ) ? "%g" % value : nil, is_extra_label( value ) ? Io::Creat::Slipstick::Entity::LOTICK : Io::Creat::Slipstick::Entity::TICK )
          end

          if j > 0
	    render_fodder( last, x, base + ( j - 1 ) * step, step, 2 )
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
    def render_fodder( start_mm, end_mm, start_val, step, h_idx_off = 2 )
      no_smallest = calc_fodder( start_mm, end_mm )
      if no_smallest > 0
        stepper = step / no_smallest
        for k in 1..no_smallest - 1
          value = start_val + k * stepper
          mx = @start_mm + @dir * Math.log10( compute( value ) ) * @scale
            h_idx = h_idx_off + @dim[Io::Creat::Slipstick::Key::FODDERS][no_smallest].length + 1
            @dim[Io::Creat::Slipstick::Key::FODDERS][no_smallest].each_with_index do | mod, index |
              if k % ( no_smallest / mod ) == 0
                h_idx = h_idx_off + 1 + index
                break
              end
            end
          h = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
          value = value.round( 2 )
          render_tick( mx, h, is_extra_label( value ) ? "%g" % ( value * 10 ) : nil, Io::Creat::Slipstick::Entity::LOTICK )
        end
      end
    end

    # fill range given by border with short scale of log() for values under 1 to the left of the 1 tick
    private
    def render_subscales ( )
               # match flag, start val    start pos                    step                    length
      data = [ [ Io::Creat::Slipstick::Flag::RENDER_SUBSCALE, 1,           @start_mm,                   -0.02,                  @inverse ? @w_after_mm : @w_subscale_mm ], # subscale
               [ Io::Creat::Slipstick::Flag::RENDER_AFTERSCALE, 10 ** @size, @start_mm + @dir * @w_mainscale_mm, 0.05 * ( 10 ** @size ), @inverse ? @w_subscale_mm : @w_after_mm ] ] # afterscale
      data.each do | match, value, start_mm, step, threshold_mm |
        if threshold_mm <= 0 or @flags & match == 0
          next
        end

        prev_h_idx = 0
        last = start_mm
        while true do
          value += step
          x = @start_mm + @dir * Math.log10( value ) * @scale
          if ( x.abs - start_mm ).abs >= threshold_mm
            break
          end
	  
          h_idx = 3
          case match
            when Io::Creat::Slipstick::Flag::RENDER_SUBSCALE
              round = ( value * 20 ).round( 2 ) % 2 == 0
              h_idx = round ? 3 : 4
              label = value < 1 && round ? ( "%.1f" % value )[1..-1] : nil
            when Io::Creat::Slipstick::Flag::RENDER_AFTERSCALE
              round = ( value * 10 ** @size ).round( 2 ) % 10 ** ( @size + 1 ) == 0
              h_idx -= 1
              label = round ? "%g" % value : nil
          end
          h = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
          render_tick( x, h, label, Io::Creat::Slipstick::Entity::LOTICK )

          render_fodder( last, x, value - step, step, [ h_idx, prev_h_idx ].max )
          last = x
          prev_h_idx = h_idx
        end
      end
    end

  end
end

