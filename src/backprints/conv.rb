
# vim: et

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # teeny-tiny scale explaining relationship between two units from different
  # standards
  class ConversionBackprint < Backprint

    # length
    CM_INCH = { :scale => 2.54, :bigger => [ "inch", "inches" ], :smaller => [ "cm", "cm" ], :real => 25.4 }
    FOOT_M  = { :scale => 1 / 0.3048, :bigger => [ "m", "m" ], :smaller => [ "foot", "feet" ], :real => 25 }
    YARD_M = { :scale => 1 / 0.9144, :bigger => [ "m", "m" ], :smaller => [ "yard", "yards" ], :real => 25 }
    KM_MILE = { :scale => 1.609, :bigger => [ "mile", "miles" ], :smaller => [ "km", "km" ], :real => 40.1125 }
    KM_NMILE = { :scale => 1.853184, :bigger => [ "nautical mile", "nautical miles" ], :smaller => [ "km", "km" ], :real => 185.3184 / 4 }

    # weight
    OZ_G = { :scale => 28.3495, :bigger => [ "ounce", "ounces" ], :smaller => [ "g", "g" ], :real => 28.3495 }
    POUND_KG = { :scale => 1 / 0.45359, :bigger => [ "kg", "kg" ], :smaller => [ "pound", "pounds" ], :real => 25 }
    KG_STONE = { :scale => 6.3503, :bigger => [ "stone", "stones" ], :smaller => [ "kg", "kg" ], :real => 31.5 }

    def set_scale ( scale, w_mm )
      @scale = scale
      @w_mm  = w_mm
      @dim   = Io::Creat::Slipstick::Dim::DEFAULT
      @fs_mm = 1.8
      @tw_mm = 0
      @labels = [ "1 %s" % @scale[:bigger][0],
                  "%.4g %s" % [ @scale[:scale], @scale[:smaller][1] ],
                  "1 %s" % @scale[:smaller][0],
                  "%.4g %s" % [ 1 / @scale[:scale], @scale[:bigger][1] ]
                ]
      # calculate max text width
      @labels[0..1].each do | label |
        @tw_mm = [ @tw_mm, label.length ].max
      end
    end

    def center_text ( text )
      for i in 1..text.length - 1
        text = "\u00a0" + text
      end
      text
    end

    def render()
      raise "set_scale() was not called" unless not @w_mm.nil?
      #fs_mm = @text_style["font-size"]
      @text_style["font-size"] = @fs_mm
      h_mm = @fs_mm / 1.5
      off_x_mm = @w_mm * @scale[:real]
      @img.line( @x_mm, @y_mm, @x_mm + off_x_mm, @y_mm, @line_style )
      @img.line( @x_mm, @y_mm - h_mm, @x_mm, @y_mm + h_mm, @line_style)
      @img.line( @x_mm + off_x_mm, @y_mm, @x_mm + off_x_mm, @y_mm + h_mm, @line_style )
      text = center_text( @labels[0] )
      @img.text( @x_mm + off_x_mm, @y_mm + h_mm + @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] * @fs_mm, text, @text_style )
      text = center_text( @labels[1] )
      @img.text( @x_mm + off_x_mm, @y_mm + h_mm + @fs_mm + @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] * @fs_mm, text, @text_style )
      off_x_mm = @w_mm * @scale[:real] / @scale[:scale]
      @img.line( @x_mm + off_x_mm, @y_mm, @x_mm + off_x_mm, @y_mm - h_mm, @line_style )
      text = center_text( @labels[2] )
      @img.text( @x_mm + off_x_mm, @y_mm - h_mm + @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] * @fs_mm, text, @text_style )
      text = center_text( @labels[3] )
      @img.text( @x_mm + off_x_mm, @y_mm - h_mm - @fs_mm + @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] * @fs_mm, text, @text_style )
    end

    def getw()
      return @w_mm * @scale[:real] + 0.6 * @tw_mm * @fs_mm
    end

  end # ConversionBackprint

end # Io::Creat::Slipstick::Backprints

