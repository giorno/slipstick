#!/usr/bin/ruby

# vim: et

require_relative 'qr'
require_relative 'sheet'
require_relative 'backprints/constants'
require_relative 'backprints/conv'
require_relative 'backprints/instr'
require_relative 'backprints/log'
require_relative 'backprints/pageno'
require_relative 'backprints/scales'
require_relative 'backprints/trigon'

include Io::Creat::Slipstick::Backprints

module Io::Creat::Slipstick
  module Model

    # model A inspired by layout of LOGAREX 27403-II
    class A < Io::Creat::Slipstick::Layout::Sheet
      # layers to generate
      LAYER_FACE    = 0x1 # front side (page) of a printout list
      LAYER_REVERSE = 0x2 # reverse side of the printout`
      LAYER_STOCK   = 0x4 # generate stator if set, slide if not set

      # branding/version texts on the stock face
      STYLE_BRAND   = { "font-size" => "2.4",
                        "font-family" => "Slipstick Sans Mono",
                        "font-weight" => "normal",
                        "fill" => "#102a87",
                        "text-anchor" => "middle" }
      # QR code style
      STYLE_QR      = { :fill => "black", :stroke_width => "0.01", :stroke => "black" }
      PATTERN_BEND  = "1, 1" # line pattern for bent edges

      public
      def initialize ( layers = LAYER_FACE | LAYER_REVERSE )
        super()
        @version = "ts0x%s" % Time.now.getutc().to_i().to_s( 16 )
        @layers = layers
        @bprints = [] # backprints
        @hu_mm = 22.0 # height of upper half of stator strip
        @hl_mm = 22.0 # height of lower half of stator strip
        @hs_mm = 18.0 # height of slipstick strip
        @t_mm  = 1.5 # thickness of the slipstick
        @sh_mm = @h_mm # sheet height
        @h_mm  = @hu_mm + @hl_mm + @hs_mm
        @x_mm  = 5.0
        @y_mm  = 10.0
        @w_mm  = 287.0
        @b_mm  = 0.1 # bending radius (approximated)
        @ct_mm = 2.0 # thickness of cursor
        @cc_mm = 2.0 # compensation to add to cursor height
        @cs_mm = 0.5 # correction for slide height

        w_m_mm = 250.0
        w_l_mm = 7.0
        w_s_mm = 23.0
        w_a_mm = 7.0

        # scales of the stator
        if ( ( @layers & LAYER_STOCK ) != 0 ) and ( ( @layers & LAYER_FACE ) != 0 )
          # bottom stock strip
          strip = create_strip( @x_mm, @y_mm, @hl_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 0.5 )
              scale.set_params( 1 )
              scale.add_constants( )
              scale.set_overflow( 1.0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SIN, "sin", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 90, 5, [ 1, 5, 10, 20 ] )
              scale.set_flags( 0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_TAN, "tan", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 45, 5, [ 1, 5, 10, 20 ] )
              scale.set_flags( 0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SINTAN, "sin-tan", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 6, 0.5, [ 1.0 / 12.0, 0.5 ], 8 )
              scale.set_flags( 0 )
              scale.set_overflow( @b_mm )

          # top of the stock back
          strip = create_strip( @x_mm, @y_mm + @t_mm + @hl_mm, 8, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "cm", 0.33 )
              scale.set_params( 25 )
              scale.set_overflow( @b_mm )

          # bottom of the stock back
          strip = create_strip( @x_mm, @y_mm + @t_mm + @h_mm + @hl_mm - 8, 8, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_INCH, "inches", 0.33, true )
              scale.set_params( 10 )
              scale.set_overflow( @b_mm )

          # top stock strip
          strip = create_strip( @x_mm, @y_mm + 2 * @t_mm + @h_mm + @hu_mm, @hu_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "log", 0.33 )
              scale.set_params( 10 )
              scale.set_overflow( @b_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_PYTHAG, "√1-x²", 0.33 )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x³", 0.33 )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 3 )
              scale.set_flags( 0 )
              scale.add_constants( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0.5, true )
              scale.set_params( 2 )
              scale.add_constants( )
              scale.set_overflow( 1.0 )

          # backprints
          @bp_border_mm = 12.0
          @bp_y_mm = @y_mm + @hl_mm + @t_mm + @bp_border_mm
          @bp_h_mm = @h_mm - 2 * @bp_border_mm
          @bp_x_mm = @x_mm + @bp_border_mm / 2

          # scales layout
          lo = ScalesBackprint.new( @img, @bp_x_mm, @bp_y_mm, @bp_h_mm )
            @bprints << lo
            @bp_x_mm += @bp_border_mm / 2 + lo.getw()

          # sin-cos help
          gr = TrigonometricBackprint.new( @img, @bp_x_mm, @bp_y_mm, @bp_h_mm )
            @bprints << gr
            @bp_x_mm += @bp_border_mm / 2 + gr.getw()

          # log help
          gr = LogBackprint.new( @img, @bp_x_mm, @bp_y_mm, @bp_h_mm )
            @bprints << gr
            @bp_x_mm += @bp_border_mm / 2 + gr.getw()

          # table of scale labels
          cbp = ConstantsBackprint.new( @img, @bp_x_mm, @bp_y_mm, @bp_h_mm )
            @bprints << cbp
            @bp_x_mm += @bp_border_mm / 2 + cbp.getw()

          # page number
          pn = PageNoBackprint.new( @img, @x_mm + @w_mm / 2, @sh_mm - @y_mm, 6 )
            pn.sett( 'STOCK + CURSOR (210 g/m²)' )
            @bprints << pn
       end

        # sides of the slide
        if ( ( @layers & LAYER_STOCK ) == 0 ) and ( ( @layers & LAYER_FACE ) != 0 )

          # temperature conversion scale
          bp_off_mm = 9 # offset of conversion scales from the edge of slide
          strip = create_strip( @x_mm, @y_mm + bp_off_mm - @hu_mm / 4 , @hu_mm / 2, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_TEMP, "°C", 0.5, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( -50.0, 200.0, 1.0, true )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_TEMP, "°F", 0.5 )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( -58.0, 392.0, 1.0 )

          # power scales
          strip = create_strip( @x_mm, @y_mm + ( ( @h_mm - @hs_mm ) / 2 ), @hs_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e⁰·⁰¹ˣ", 0.5 )
              scale.set_params( 100 )
              scale.set_overflow( 4.0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e⁰·¹ˣ", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 10 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e¹ˣ", 0.5, true )
              scale.set_params( 1 )
              scale.set_overflow( 4.0 )

          # length units conversion scales
          bp_w_mm = w_m_mm + w_l_mm + w_s_mm + w_a_mm # width reserved for the 
          bp_gap_mm = 10 # space between conversion scales
          @bprints << ConversionBackprints.new( @img, @x_mm, @x_mm + bp_w_mm, @y_mm + @h_mm - bp_off_mm, bp_gap_mm, ConversionBackprint::LENGTHS )

          # page number
          pn = PageNoBackprint.new( @img, @x_mm + @w_mm / 2, @sh_mm - @y_mm, 6 )
            pn.sett( 'SLIDE (210 g/m²)' )
            @bprints << pn

          # log scales
          strip = create_strip( @x_mm, @y_mm + @h_mm - @cs_mm + ( ( @h_mm - @hs_mm ) / 2 ), @hs_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0.5 )
              scale.set_params( 2 )
              scale.set_overflow( 4.0 )
              scale.add_constants( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "1/x", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 1, true )
              scale.add_constants( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 0.5, true )
              scale.set_params( 1 )
              scale.set_overflow( 4.0 )
              scale.add_constants( )

          # rest of units conversion scales
          @bprints << ConversionBackprints.new( @img, @x_mm, @x_mm + bp_w_mm, @y_mm + @h_mm - @cs_mm + bp_off_mm, bp_gap_mm, ConversionBackprint::WEIGHTS + ConversionBackprint::AREAS )
          @bprints << ConversionBackprints.new( @img, @x_mm, @x_mm + bp_w_mm, @y_mm + 2 * ( @h_mm - @cs_mm ) - bp_off_mm, bp_gap_mm, ConversionBackprint::VOLUMES )
        end
      end
      
      # allows to create strip with absolute positioning
      private
      def create_strip( x_mm, y_mm, h_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
        strip = super( h_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
        strip.instance_variable_set( :@off_x_mm, x_mm )
        strip.instance_variable_set( :@off_y_mm, y_mm )
        return strip
      end

      private
      def render_cursor ( y_mm, dir )
        w_mm = 40.0
        if dir == -1 then y_mm -= w_mm end
        h_mm = @cc_mm + @h_mm + @b_mm
        s_mm = @ct_mm + @b_mm
        b_mm = 15.0 # overlap
        rw_mm = 2 * h_mm + b_mm + 2 * s_mm # projected width of rectangle
        x_mm = @x_mm + ( @w_mm - rw_mm ) / 2
        if ( @layers & LAYER_FACE ) != 0
          # instructions
          off = 0.05
          csr = InstructionsBackprint.new( @img, x_mm + rw_mm - h_mm + h_mm * off, y_mm + h_mm * off, h_mm * ( 1 - 2 * off ) )
          csr.setw( w_mm - h_mm * 2 * off )
          csr.render()
          # contour
          @img.pbegin()
            @img.move( x_mm, y_mm )
            @img.rline( x_mm + b_mm + s_mm, y_mm )
            # circular cutout
            @img.arc( x_mm + b_mm + s_mm + h_mm, y_mm, 0.75 * h_mm, "0,0" )
            @img.rline( x_mm + rw_mm, y_mm )
            @img.rline( x_mm + rw_mm, y_mm + w_mm )
            @img.rline( x_mm, y_mm + w_mm )
            @img.rline( x_mm, y_mm )
          @img.pend( @style )
          if ( @layers & LAYER_REVERSE ) == 0
            # bending edges
            [ b_mm, s_mm, h_mm, s_mm ].each do | w |
              x_mm += w
              @img.pline( x_mm, y_mm, x_mm, y_mm + 2.0, @style )
              @img.pline( x_mm, y_mm + w_mm, x_mm, y_mm + w_mm - 2.0, @style )
            end
          else # debug mode
            # bending edges
            [ b_mm, s_mm, h_mm, s_mm ].each do | w |
              x_mm += w
              @img.pline( x_mm, y_mm, x_mm, y_mm + w_mm, @style, PATTERN_BEND )
            end
          end
        end
      end

      # render strips and edges for cutting/bending
      public
      def render()
        @style = { :stroke_width => "0.1", :stroke => "black", :stroke_cap => "square", :fill => "none" }
        # stock lines are intentionally positioned upside down (in landscape)
        if ( @layers & LAYER_STOCK ) != 0
          # both on same sheet?
          rh_mm = @hu_mm + 2 * @t_mm + @h_mm + @hl_mm # height of rectangle
          dir, y_mm = ( @layers & LAYER_FACE ) == 0 ? [ -1, @sh_mm - @y_mm - rh_mm ] : [ 1, @y_mm ]
          if ( @layers & LAYER_REVERSE ) != 0
            # bending guidelines for the stator
            @img.pline( @x_mm, y_mm + @hu_mm, @x_mm + @w_mm, y_mm + @hu_mm, @style, PATTERN_BEND )
            @img.pline( @x_mm, y_mm + ( @hu_mm + @t_mm ), @x_mm + @w_mm, y_mm + ( @hu_mm + @t_mm ), @style, PATTERN_BEND )
            @img.pline( @x_mm, y_mm + ( @hu_mm + @t_mm + @h_mm ), @x_mm + @w_mm, y_mm + ( @hu_mm + @t_mm + @h_mm ), @style, PATTERN_BEND )
            @img.pline( @x_mm, y_mm + ( @hu_mm + 2 * @t_mm + @h_mm ), @x_mm + @w_mm, y_mm + ( @hu_mm + 2 * @t_mm + @h_mm ), @style, PATTERN_BEND )
          end
          if ( @layers & LAYER_FACE ) != 0
            # cutting guidelines for the stator
            @img.rectangle( @x_mm, y_mm, @w_mm, rh_mm, @style )
            # branding texts
            @img.text( @x_mm + 174, @y_mm + 105, "creat.io MODEL A", STYLE_BRAND )
            bottom_off_mm = 15.0
            bottom_mm = @y_mm + bottom_off_mm + @hl_mm + @t_mm
            gr_size_mm = @h_mm - ( 2 * bottom_off_mm )
            # QR code
            # TODO refactor to inherit from Backprint
            qr = Qr.new( @img, 'http://www.creat.io/slipstick', 4, :h, @x_mm + @w_mm - gr_size_mm - bottom_off_mm, bottom_mm, gr_size_mm, STYLE_QR )
            @img.rtext( @x_mm + @w_mm - 5, @y_mm + @hl_mm + @t_mm + @h_mm / 2, -90, @version, STYLE_BRAND )
          end
          if dir < 0 then rh_mm = 0 end
          render_cursor( y_mm + dir * ( rh_mm + @y_mm ), dir )
        end
        # backprints
        @bprints.each do | bp |
          bp.render()
        end
        if ( ( @layers & LAYER_STOCK ) == 0 ) and ( ( @layers & LAYER_REVERSE ) != 0 )
          # cutting guidelines for the slipstick
          both = ( @layers & LAYER_FACE ) != 0
          y_mm = !both ? @sh_mm - @y_mm - 2 * ( @h_mm - @cs_mm ) : @y_mm
          @img.line( 0, y_mm + @cs_mm, 297, y_mm + @cs_mm, @style )
          @img.pline( 0, y_mm + @h_mm - @cs_mm, 297, y_mm + @h_mm - @cs_mm, @style, PATTERN_BEND )
          @img.line( 0, y_mm + 2 * ( @h_mm - @cs_mm ), 297, y_mm + 2 * ( @h_mm - @cs_mm ), @style )
          # debugging mode, outline borders of area visible in the stock
          if both
            # power scales side
            @img.line( 0, y_mm + @hu_mm, 297, y_mm + @hu_mm, @style )
            @img.line( 0, y_mm + @hu_mm + @hs_mm, 297, y_mm + @hu_mm + @hs_mm, @style )
            # decimal scales side
            @img.line( 0, y_mm + @hu_mm + @h_mm - @cs_mm, 297, y_mm + @hu_mm + @h_mm - @cs_mm, @style )
            @img.line( 0, y_mm + @hu_mm + @h_mm - @cs_mm + @hs_mm, 297, y_mm + @hu_mm + @h_mm - @cs_mm + @hs_mm, @style )
          end
        end
        # strips
        super( true )
        @img.close()
        return @img.output
      end

    end # A

  end # Model
end # Io::Creat::Slipstick

def usage ( )
  $stderr.puts "Usage: #{$0} <stator|slide>> [both|face|reverse]\n\nOutputs SVG for requested side of the slide rule printout."
end

layers = 0
if ARGV.length == 0
  usage( )
  raise "Requires either 'stock' or 'slide' as first parameter"
end

if ARGV.length >= 1
  if ARGV[0] == 'stock'
    layers = Io::Creat::Slipstick::Model::A::LAYER_STOCK
  elsif ARGV[0] != 'slide'
    usage( )
  end
end

if ARGV.length > 1
  if ARGV[1] == 'face'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_FACE
  elsif ARGV[1] == 'reverse'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_REVERSE
  elsif ARGV[1] == 'both'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_FACE | Io::Creat::Slipstick::Model::A::LAYER_REVERSE
  else
    $stderr.puts "Usage: #{$0} <stator|slide>> [both|face|reverse]\n\nOutputs SVG for requested side of the slide rule printout."
    exit
  end
end

a = Io::Creat::Slipstick::Model::A.new( layers )
puts a.render()

