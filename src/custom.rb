
# vim: et

require_relative 'constants'
require_relative 'scale'

module Io::Creat::Slipstick

  # linear scale with custom units and labels
  class CustomScale < Scale

    public
    def set_params ( start_val, end_val, step_val, line = false, labels = true )
      @start_val   = start_val
      @end_val     = end_val
      @step_val    = step_val
      @size        = @end_val - @start_val
      @initialized = true
      @scale       = @w_mainscale_mm / @size
      @line        = line # draw line
      @labels      = labels # render labels
    end

    public
    def calc_tick_font_height_mm ( )
      if not @labels
        return 0
      else
        return super()
      end
    end

    # override in specializations
    public
    def label ( val )
      return "%d" % val
    end

    # override in specialization
    public
    def height_index ( val )
      return val % 16 == 0 ? 0 : ( val % 8 == 0 ? 1 : 3 )
    end

    public
    def render ( )
      last_mm = @start_mm
      ( @start_val..@end_val ).step( @step_val ) do | val |
        x_mm = @start_mm + ( ( val - @start_val ) * @scale )
	h_idx = height_index( val )
        h_mm = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx]
	render_tick( x_mm, h_mm, label( val ) )
	last_mm = x_mm
      end
      if @line
        y_mm = @off_y_mm
        style = Io::Creat::Slipstick::Entity::TICK
        @img.line( @off_x_mm + @start_mm, y_mm, @off_x_mm + @start_mm + @w_mainscale_mm, y_mm, { "stroke" => @style[style][Io::Creat::Slipstick::Key::LINE_COLOR], "stroke-width" => "%f" % @style[style][Io::Creat::Slipstick::Key::LINE_WIDTH], "stroke-linecap" => "butt" } )
      end
      render_label( )
    end

  end # CustomScale

  class HexGradeScale < CustomScale

    def label ( val )
      if not @labels
        return nil
      end
      return val == 0 ? "HEX 0\u00a0\u00a0\u00a0\u00a0\u00a0" : ( val % 8 == 0 ? "%x" % val : nil )
    end

    def height_index ( val )
      return val % 16 == 0 ? 0 : ( val % 8 == 0 ? 1 : 3 )
    end

  end # HexGradeScale

  class DecGradeScale < CustomScale

    def label ( val )
      if not @labels
        return nil
      end
      return val == 0 ? "DEC 0\u00a0\u00a0\u00a0\u00a0\u00a0" : ( val % 10 == 0 ? "%d" % val : nil )
    end

    def height_index ( val )
      return val % 10 == 0 ? 0 : ( val % 5 == 0 ? 1 : 3 )
    end

  end # DecGradeScale

  class OctGradeScale < CustomScale

    def label ( val )
      if not @labels
        return nil
      end
      return val == 0 ? "OCT 0\u00a0\u00a0\u00a0\u00a0\u00a0" : ( val % 8 == 0 ? "%d" % val.round.to_s( 8 ) : nil )
    end

    def height_index ( val )
      return val % 8 == 0 ? 0 : ( val % 4 == 0 ? 1 : 3 )
    end

  end # OctGradeScale

  class BinGradeScale < CustomScale

    def label ( val )
      if not @labels
        return nil
      end
      return val == 0 ? "BIN 0\u00a0\u00a0\u00a0\u00a0\u00a0" : ( val % 16 == 0 ? "%d" % val.round.to_s( 2 ) : nil )
    end

    def height_index ( val )
      return val % 16 == 0 ? 0 : ( val % 8 == 0 ? 1 : 3 )
    end

  end # BinGradeScale

  class DegGradeScale < CustomScale

    def label ( val )
      if not @labels
        return nil
      end
      return val == 0 ? "DEG 0\u00b0\u00a0\u00a0\u00a0\u00a0" : ( val % 15 == 0 ? "\u00a0%d\u00b0" % val : nil )
    end

    def height_index ( val )
      return val % 15 == 0 ? 0 : ( val % 5 == 0 ? 1 : 3 )
    end

  end # DegGradeScale

  class RadGradeScale < CustomScale

    def label ( val )
      if not @labels
        return nil
      end
      return val == 0 ? "RAD 0\u00a0\u00a0\u00a0\u00a0\u00a0" : ( val % 1 == 0 ? "%d" % val : nil )
    end

    def height_index ( val )
      return val % 1 == 0 ? 0 : ( val % 0.5 == 0 ? 1 : ( ( val * 10 ).round( 1 ) % 1 == 0 ? 3 : 5 ) )
    end

    def render ( )
      super()
      val = Math::PI
      x_mm = @start_mm + ( ( val - @start_val ) * @scale )
      render_tick( x_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][0], @labels ? "\u03c0" : nil )
      val = 2 * Math::PI
      x_mm = @start_mm + ( ( val - @start_val ) * @scale )
      render_tick( x_mm, @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][0], @labels ? "2\u03c0" : nil )
    end

  end # RadGradeScale

  class GradGradeScale < CustomScale

    def label ( val )
      if not @labels
        return nil
      end
      return val == 0 ? "GRAD 0\u00a0\u00a0\u00a0\u00a0\u00a0\u00a0" : ( val % 10 == 0 ? "%d" % val : nil )
    end

    def height_index ( val )
      return val % 10 == 0 ? 0 : ( val % 5 == 0 ? 1 : 3 )
    end

  end # GradGradeScale

end # Io::Creat::Slipstick

