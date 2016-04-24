
# vim: et

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # teeny-tiny scale explaining relationship between two units from different
  # standards
  class ConversionBackprint < Backprint

    # SI vs. imperial length units
    #            bigger/smaller, singular/plural of bigger      , sg/pl of smaller          , suggested size on paper [mm]
    CM_INCH  = { :scale => 2.54, :bigger => [ "inch", "inches" ], :smaller => [ "cm", "cm" ], :real => 25.4 }
    FOOT_M   = { :scale => 1 / 0.3048, :bigger => [ "m", "m" ], :smaller => [ "foot", "feet" ], :real => 25 }
    YARD_M   = { :scale => 1 / 0.9144, :bigger => [ "m", "m" ], :smaller => [ "yard", "yards" ], :real => 25 }
    KM_MILE  = { :scale => 1.609, :bigger => [ "mile", "miles" ], :smaller => [ "km", "km" ], :real => 40.1125 }
    KM_NMILE = { :scale => 1.853184, :bigger => [ "nautical_mile", "nautical_miles" ], :smaller => [ "km", "km" ], :real => 185.3184 / 4 }

    # SI vs. imperial weight units
    OZ_G     = { :scale => 28.3495, :bigger => [ "ounce", "ounces" ], :smaller => [ "g", "g" ], :real => 28.3495 }
    TOZ_G    = { :scale => 31.1034768, :bigger => [ "troy_ounce", "troy_ounces" ], :smaller => [ "g", "g" ], :real => 31.1034768 }
    POUND_KG = { :scale => 1 / 0.45359, :bigger => [ "kg", "kg" ], :smaller => [ "pound", "pounds" ], :real => 25 }
    KG_STONE = { :scale => 6.3503, :bigger => [ "stone", "stones" ], :smaller => [ "kg", "kg" ], :real => 31.5 }

    # SI vs. imperial area units
    ACRE_HA  = { :scale => 10 / 4.0468564, :bigger => [ "ha", "ha" ], :smaller => [ "acre", "acres" ], :real => 25 }
    SQFT_M2  = { :scale => 1 / 0.09290, :bigger => [ "m²", "m²" ], :smaller => [ "square_foot", "square_feet" ], :real => 25 }

    # SI vs. imperial volume units
    PINT_L   = { :scale => 1 / 0.56826, :bigger => [ "l", "l" ], :smaller => [ "pint", "pints" ], :real => 25 }
    L_QUART  = { :scale => 1.13652, :bigger => [ "quart", "quarts" ], :smaller => [ "l", "l" ], :real => 20 * 1.13652 }
    L_GALLON = { :scale => 4.54609, :bigger => [ "gallon", "gallons" ], :smaller => [ "l", "l" ], :real => 5 * 4.54609 }

    # collections
    LENGTHS = [ CM_INCH, FOOT_M, YARD_M, KM_MILE, KM_NMILE ]
    WEIGHTS = [ OZ_G, TOZ_G, POUND_KG, KG_STONE ]
    AREAS   = [ ACRE_HA, SQFT_M2 ]
    VOLUMES = [ PINT_L, L_QUART, L_GALLON ]

    public
    def set_scale ( scale, fs_mm = 1.8 )
      @scale = scale
      @dim   = Io::Creat::Slipstick::Dim::DEFAULT
      @fs_mm = fs_mm
      @tw_mm = 0
      @i18n = Io::Creat::Slipstick::I18N.instance
      @labels = [ "1 %s" % @i18n.string( @scale[:bigger][0] ),
                  "%0.7g %s" % [ @scale[:scale], @i18n.string( @scale[:smaller][1] ) ],
                  "1 %s" % @i18n.string( @scale[:smaller][0] ),
                  "%0.7g %s" % [ 1 / @scale[:scale], @i18n.string( @scale[:bigger][1] ) ]
                ]
      # calculate max text width
      @labels[0..1].each do | label |
        @tw_mm = [ @tw_mm, label.length ].max
      end
      @text_style[:font_size] = @fs_mm
    end

    # adds number of unbreakable spaces in front of the test to make first
    # character appear in center
    private
    def center_text ( text )
      for i in 1..text.length - 1
        text = "\u00a0" + text
      end
      text
    end

    public
    def render()
      raise "set_scale() was not called" unless not @labels.nil?
      h_mm = @fs_mm / 1.75 # tick height
      off_x_mm = @scale[:real]
      @img.line( @x_mm, @y_mm, @x_mm + off_x_mm, @y_mm, @line_style ) # horizontal
      @img.line( @x_mm, @y_mm - h_mm, @x_mm, @y_mm + h_mm, @line_style) # zero
      # bigger one
      @img.line( @x_mm + off_x_mm, @y_mm, @x_mm + off_x_mm, @y_mm + h_mm, @line_style )
      text = center_text( @labels[0] )
      @img.text( @x_mm + off_x_mm, @y_mm + h_mm + @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] * @fs_mm, text, @text_style )
      text = center_text( @labels[1] )
      @img.text( @x_mm + off_x_mm, @y_mm + h_mm + @fs_mm + @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] * @fs_mm, text, @text_style )
      # smaller one
      off_x_mm = @scale[:real] / @scale[:scale]
      @img.line( @x_mm + off_x_mm, @y_mm, @x_mm + off_x_mm, @y_mm - h_mm, @line_style )
      text = center_text( @labels[2] )
      @img.text( @x_mm + off_x_mm, @y_mm - h_mm + @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] * @fs_mm, text, @text_style )
      text = center_text( @labels[3] )
      @img.text( @x_mm + off_x_mm, @y_mm - h_mm - @fs_mm + @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] * @fs_mm, text, @text_style )
    end

    public
    def setx ( x_mm )
      @x_mm = x_mm
    end

    public
    def getx ( )
      return @x_mm
    end

    public
    def getw()
      return @scale[:real] + FONT_WH_RATIO * @tw_mm * @fs_mm
    end

  end # ConversionBackprint

  # collection of conversion scales manipulated as single object
  # positioned in the middle of horizontal range
  # TODO move to another .rb file
  class ConversionBackprints

    public
    def initialize ( img, left_mm, right_mm, y_mm, gap_mm, scales = [] )
      raise "No conversion scales" unless scales.length > 0
      @scales = scales
      @bprints = []
      x_mm = left_mm
      scales.each do | scale |
        bp = ConversionBackprint.new( img, x_mm, y_mm, 0 )
        bp.set_scale( scale )
        x_mm += bp.getw() + gap_mm
        @bprints << bp
      end
      # adjust positions to make the whole collection centered
      x_mm -= gap_mm
      w_mm = x_mm - left_mm
      adj_mm = ( ( right_mm - left_mm ) - w_mm ) / 2
      @bprints.each do | bp |
        bp.setx( bp.getx() + adj_mm )
      end
    end

    public
    def render ( )
      @bprints.each do | bprint |
        bprint.render()
      end
    end

  end # ConversionBackprints

end # Io::Creat::Slipstick::Backprints

