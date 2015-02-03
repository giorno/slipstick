
# vim: et

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # teeny-tiny scale explaining relationship between two units from different
  # standards
  class ConversionBackprint < Backprint

    CM_INCH = { :scale => 2.54, :bigger => [ "inch", "inches" ], :smaller => [ "cm", "cm" ], :real => 25.4 }
    FOOT_M  = { :scale => 1/0.3048, :bigger => [ "m", "m" ], :smaller => [ "foot", "feet" ], :real => 50 }
    KM_MILE = { :scale => 1.609, :bigger => [ "mile", "miles" ], :smaller => [ "km", "km" ], :real => 40.1125 }

    def set_scale ( scale, w_mm )
      @scale = scale
      @w_mm  = w_mm
    end

    def render()
      raise "set_scale() was not called" unless not @w_mm.nil?
      fs_mm = 1.8
      #fs_mm = @text_style["font-size"]
      @text_style["font-size"] = fs_mm
      h_mm = fs_mm
      off_x_mm = @w_mm * @scale[:real]
      @img.line( @x_mm, @y_mm, @x_mm + off_x_mm, @y_mm, @line_style )
      @img.line( @x_mm, @y_mm - h_mm, @x_mm, @y_mm + h_mm, @line_style)
      @img.line( @x_mm + off_x_mm, @y_mm, @x_mm + off_x_mm, @y_mm + h_mm, @line_style )
      @img.text( @x_mm + off_x_mm, @y_mm + h_mm + fs_mm, "1%s (%.4g%s)" % [ @scale[:bigger][0], @scale[:scale], @scale[:smaller][1] ], @text_style )
      off_x_mm = @w_mm * @scale[:real] / @scale[:scale]
      @img.line( @x_mm + off_x_mm, @y_mm, @x_mm + off_x_mm, @y_mm - h_mm, @line_style )
      @img.text( @x_mm + off_x_mm, @y_mm - h_mm,  "1%s (%.4g%s)" % [ @scale[:smaller][0], 1 / @scale[:scale], @scale[:bigger][0] ], @text_style )
    end

    def getw()
      return @w_mm * @scale[:real]
    end

  end # ConversionBackprint

end # Io::Creat::Slipstick::Backprints

