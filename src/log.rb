
require_relative 'constants'
require_relative 'scale'

module Io::Creat::Slipstick

  # common functionality of all logarithmic scales
  class LogScale < Scale
    #FLAG_IGN_FULL_HEIGHT = 1
    # values [list] values to be explicitly generated at maximal height
    # small [list] values rendered with ticks of lower height (index 1)
    # nolabel [list] explicit values for which labels are not rendered
    # fodders [hash] of tuples (lower boundary, number of ticks, [list] of divisors
    public
    def set_params ( values, small = [], fodders = {}, nolabel = [] )
      @values      = values
      @small       = small
      @fodders     = fodders
      @nolabel     = nolabel
      @scale       = @w_mainscale_mm / 1
      @initialized = true
    end

    # core metod to calculate actual rendering value
    # intended for override in subclass
    protected
    def comp ( val )
      return val
    end

    # format value for rendering in tick label
    # intended for override in subclass
    protected
    def fmt ( val )
      return @nolabel.include?( val ) ? nil : "%g" % val
    end

    public
    def render ( )
      last_val = nil
      last_mm = -1
      @values.each do | val |
        x_mm = @start_mm + Math.log10( comp( val ) ) * @scale
        render_tick( x_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][ @small.include?( val ) ? 1 : 0 ], fmt( val ), @small.include?( val ) ? Io::Creat::Slipstick::Entity::LOTICK : Io::Creat::Slipstick::Entity::TICK )
        if not last_val.nil?
          render_fodder( last_val, val - last_val, 1 )
        end
        last_mm = x_mm
        last_val = val
      end
      render_label( )
    end

    # renders main scale fodders
    private
    def calc_fodder_main ( from )
      fodder = nil 
      @fodders.each do | key, fod |
        if key > from then break end
        fodder = fod
      end
      return fodder
    end

    # internal method rendering fodder ticks
    private
    def render_fodder_int ( fodder, from, step, h_idx_off = 3 )
      if !fodder.nil?
        stepper = step / fodder[0]
        for k in 1..fodder[0] - 1
          value = from + k * stepper
          mx = @start_mm + Math.log10( comp( value ) ) * @scale
            h_idx = h_idx_off + fodder[1].length + 1
            fodder[1].each_with_index do | mod, index |
              if k % mod == 0
                h_idx = h_idx_off + 1 + index
                break
              end
            end
          h = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
          value = value.round( 2 )
          render_tick( mx, h )
        end
      end
    end

    private
    def render_fodder ( from, step, h_idx_off = 3 )
      render_fodder_int( calc_fodder_main( from ), from, step, h_idx_off )
    end

  end # LogScale

end # Io::Creat::Slipstick
