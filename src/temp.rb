
# vim: et

require_relative 'constants'
require_relative 'scale'

module Io::Creat::Slipstick

  # temperature scale, Celsius by default
  class TempScale < Scale

    public
    def set_params ( start_val, end_val, step_val, line = false )
      @start_val   = start_val
      @end_val     = end_val
      @step_val    = step_val
      @size        = @end_val - @start_val
      @initialized = true
      @scale       = @w_mainscale_mm / @size
      @line        = line # draw line
    end

    public
    def render ( )
      last_mm = @start_mm
      ( @start_val..@end_val ).step( @step_val ) do | temp |
        x_mm = @start_mm + ( ( temp - @start_val ) * @scale )
	h_idx = temp % 10 == 0 ? 0 : ( temp % 5 == 0 ? 1 : 3 )
        h_mm = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
	render_tick( x_mm, h_mm, ( temp % 10 ) == 0 ? "%d%s" % [ temp, temp < 0 ? "\u00a0" : "" ] : nil )
	last_mm = x_mm
      end
      if @line
        y_mm = @off_y_mm
        style = Io::Creat::Slipstick::Entity::TICK
        @img.line( @off_x_mm, y_mm, @off_x_mm + @start_mm + @w_mainscale_mm, y_mm, { "stroke" => @style[style][:stroke], "stroke-width" => "%f" % @style[style][:stroke_width], "stroke-linecap" => "butt" } )
      end
      render_label( )
    end

  end # TempScale

end # Io::Creat::Slipstick

