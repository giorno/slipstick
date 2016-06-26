#!/usr/bin/ruby

# vim: et

require_relative 'i18n'
require_relative 'qr'
require_relative 'sheet'
require_relative 'backprints/bu_scales'
require_relative 'backprints/constants'
require_relative 'backprints/conv'
require_relative 'backprints/instr'
require_relative 'backprints/log'
require_relative 'backprints/pageno'
require_relative 'backprints/scales'
require_relative 'backprints/trigon'

include Io::Creat
include Io::Creat::Slipstick::Backprints

module Io::Creat::Slipstick
  module Model

    # Branding information content and rendering
    class Branding
    end # Branding

    # Crete pattern for communicating model dimensions to the components
    class Dimensions
      attr_accessor :hu_mm, :hl_mm, :hs_mm, :t_mm, :sh_mm, :sw_mm, :h_mm,
                    :x_mm, :y_mm, :w_mm, :b_mm, :ct_mm, :cc_mm, :cs_mm,
                    :cw_mm, :ch_mm, :hint_mm, :w_m_mm, :w_l_mm, :w_s_mm,
                    :w_a_mm

      def initialize( h_mm, w_mm )
        @hu_mm = 22.0 # height of upper half of stator strip
        @hl_mm = 22.0 # height of lower half of stator strip
        @hs_mm = 18.0 # height of slipstick strip
        @t_mm  = 1.5 # thickness of the slipstick
        @sh_mm = h_mm # sheet height
        @sw_mm = w_mm # sheet width
        @h_mm  = @hu_mm + @hl_mm + @hs_mm
        @x_mm  = 5.0
        @y_mm  = 10.0
        @w_mm  = 287.0
        @b_mm  = 0.1 # bending radius (approximated)
        @ct_mm = 2.0 # thickness of cursor
        @cc_mm = 1.5 # compensation to add to cursor height
        @cs_mm = 0.5 # correction for slide height
        @cw_mm = 40.0 # cursor width
        @ch_mm = @cc_mm + @h_mm + @b_mm # cursor height
        @hint_mm = 2.0 # bending/cutting edges hints (incomplete cut lines)
        @w_m_mm = 250.0
        @w_l_mm = 7.0
        @w_s_mm = 23.0
        @w_a_mm = 7.0
      end

    end # Dimensions

    # Single component of a Slipstick, receives the model dimenstions and
    # encapsulates the rendering logic
    class Component
      LAYER_FACE    = 0x1
      LAYER_REVERSE = 0x2

      def initilialize ( parent, face )
        @img = parent.img
        @dim = parent.dim # instance of class Dimensions
        raise "Face must be either LAYER_FACE or LAYER_REVERSE" unless ( [ LAYER_FACE, LAYER_REVERSE ].include?( face ) )
        @face = face # 0 for front, 1 for reverse
      end # initialize

    end # Component

    # model A inspired by layout of LOGAREX 27403-II
    class A < Io::Creat::Slipstick::Layout::Sheet
      # layers to generate
      LAYER_FACE    = 0x1  # front side (page) of printout sheet
      LAYER_REVERSE = 0x2  # reverse side of printout
      LAYER_STOCK   = 0x4  # generate stator and cursor elements
      LAYER_SLIDE   = 0x8  # generate slide element
      LAYER_TRANSP  = 0x10 # gneerate transparent elements

      # branding/version texts
      RELEASE       = true
      BRAND         = "CREAT.IO"
      MODEL         = "SR-M1A2"
      HEIGHT_BRAND  = 2.2
      PATTERN_BEND  = "1, 1" # line pattern for bent edges

      public
      def initialize ( layers, style )
        super()
        set_style( style )
        raise "Layer must be one of LAYER_STOCK, LAYER_SLIDE or LAYER_TRANSP" unless ( layers & 0x1c ) != 0
        @i18n = Io::Creat::Slipstick::I18N.instance
        @img.pattern( 'glued', 3 )
        if RELEASE
          @version = "%s %s" % [ @i18n.string( 'slide_rule'), MODEL ]
        else
          @version = "ts0x%s" % Time.now.getutc().to_i().to_s( 16 )
        end
        @layers = layers
        @dm = Dimensions.new( @h_mm, @w_mm )
        @bprints = [] # backprints
#        @hu_mm = 22.0 # height of upper half of stator strip
#        @hl_mm = 22.0 # height of lower half of stator strip
#        @hs_mm = 18.0 # height of slipstick strip
#        @t_mm  = 1.5 # thickness of the slipstick
#        @sh_mm = @h_mm # sheet height
#        @sw_mm = @w_mm # sheet width
#        @h_mm  = @hu_mm + @hl_mm + @hs_mm
#        @x_mm  = 5.0
#        @y_mm  = 10.0
#        @w_mm  = 287.0
#        @b_mm  = 0.1 # bending radius (approximated)
#        @ct_mm = 2.0 # thickness of cursor
#        @cc_mm = 1.5 # compensation to add to cursor height
#        @cs_mm = 0.5 # correction for slide height
#        @cw_mm = 40.0 # cursor width
#        @ch_mm = @cc_mm + @h_mm + @b_mm # cursor height
#        @hint_mm = 2.0 # bending/cutting edges hints (incomplete cut lines)
#        w_m_mm = 250.0
#        w_l_mm = 7.0
#        w_s_mm = 23.0
#        w_a_mm = 7.0

        # prepare style for smaller scales
        @style_small = @style.merge( { Io::Creat::Slipstick::Entity::TICK => @style[Io::Creat::Slipstick::Entity::LOTICK] } )
        @style_units = @style.merge( { Io::Creat::Slipstick::Entity::TICK => @style[Io::Creat::Slipstick::Entity::UNITS] } )
        @style_branding = @style[Io::Creat::Slipstick::Entity::BRANDING]
        @style_pageno = @style[Io::Creat::Slipstick::Entity::PAGENO]
        @style_aux = Io::Creat::svg_dec_style_units( @style[Io::Creat::Slipstick::Entity::AUX], SVG_STYLE_TEXT )

        # scales of the stator
        if ( ( @layers & LAYER_STOCK ) != 0 ) and ( ( @layers & LAYER_FACE ) != 0 )
          # bottom stock strip
          strip = create_strip( @dm.x_mm, @dm.y_mm, @dm.hl_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "D", 0.5 )
              scale.set_params( 1 )
              scale.add_constants( )
              scale.set_overflow( 1.0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SIN, "S", 0.33, true )
              scale.set_style( @style_small )
              scale.set_params( 90, 5, [ 1, 5, 10, 20 ] )
              scale.set_flags( 0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_TAN, "T", 0.33, true )
              scale.set_style( @style_small )
              scale.set_params( 45, 5, [ 1, 5, 10, 20 ] )
              scale.set_flags( 0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SINTAN, "ST", 0.33, true )
              scale.set_style( @style_small )
              scale.set_params( 6, 0.5, [ 1.0 / 12.0, 0.5 ], 8 )
              scale.set_flags( 0 )
              scale.set_overflow( @dm.b_mm )

          # top of the stock back
          strip = create_strip( @dm.x_mm, @dm.y_mm + @dm.t_mm + @dm.hl_mm, 8, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "cm", 0.33 )
              scale.set_params( 25 )
              scale.set_overflow( @dm.b_mm )

          # bottom of the stock back
          strip = create_strip( @dm.x_mm, @dm.y_mm + @dm.t_mm + @dm.h_mm + @dm.hl_mm - 8, 8, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_INCH, "inches", 0.33, true )
              scale.set_params( 10 )
              scale.set_overflow( @dm.b_mm )

          # top stock strip
          strip = create_strip( @dm.x_mm, @dm.y_mm + 2 * @dm.t_mm + @dm.h_mm + @dm.hu_mm, @dm.hu_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "L", 0.33 )
              scale.set_params( 10 )
              scale.set_overflow( @dm.b_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_PYTHAG, "P", 0.33 )
              scale.set_style( @style_small )
              scale.set_params( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "K", 0.33 )
              scale.set_style( @style_small )
              scale.set_params( 3 )
              scale.set_flags( 0 )
              scale.add_constants( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "A", 0.5, true )
              scale.set_params( 2 )
              scale.add_constants( )
              scale.set_overflow( 1.0 )

          # backprints
          @bp_border_mm = 12.0
          @bp_y_mm = @dm.y_mm + @dm.hl_mm + @dm.t_mm + @bp_border_mm
          @bp_h_mm = @dm.h_mm - 2 * @bp_border_mm
          @bp_x_mm = @dm.x_mm + 0.5 * @bp_border_mm

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

          # table of mathematical and physical constants
          cbp = ConstantsBackprint.new( @img, @bp_x_mm, @bp_y_mm, @bp_h_mm )
            @bprints << cbp
            @bp_x_mm += @bp_border_mm / 2 + cbp.getw()

          # page number
          pn = PageNoBackprint.new( @img, @dm.x_mm + @dm.w_mm / 2, @dm.sh_mm - @dm.y_mm, 6, @style_pageno )
            pn.sett( '%s + %s (210 g/m²)' % [ @i18n.string( 'part_stock' ), @i18n.string( 'part_cursor' )  ] )
            @bprints << pn
       end

        # sides of the slide
        if ( ( @layers & LAYER_SLIDE ) != 0 )
          bp_off_mm = 9 # offset of conversion scales from the edge of slide
          if ( ( @layers & LAYER_FACE ) != 0 )

            # temperature conversion scale
            strip = create_strip( @dm.x_mm, @dm.y_mm + bp_off_mm - @dm.hu_mm / 4 , @dm.hu_mm / 2, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_TEMP, "°C", 0.5, true )
                scale.set_style( @style_units )
                scale.set_params( -50.0, 200.0, 1.0, true )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_TEMP, "°F", 0.5 )
                scale.set_style( @style_units )
                scale.set_params( -58.0, 392.0, 1.0 )

            # power scales
            ll_off_mm = 4 # shift LL scales to the left to make room for the last (too wide) tick label
            strip = create_strip( @dm.x_mm, @dm.y_mm + ( ( @dm.h_mm - @dm.hs_mm ) / 2 ), @dm.hs_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm - ll_off_mm, @dm.w_a_mm )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "LL1", 0.5 )
                scale.set_params( 100 )
                scale.set_overflow( 4.0 )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "LL2", 0.33, true )
                scale.set_style( @style_small )
                scale.set_params( 10 )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "LL3", 0.5, true )
                scale.set_params( 1 )
                scale.set_overflow( 4.0 )

            # length units conversion scales
            bp_w_mm = @dm.w_m_mm + @dm.w_l_mm + @dm.w_s_mm + @dm.w_a_mm # width reserved for the 
            bp_gap_mm = 10 # space between conversion scales
            @bprints << ConversionBackprints.new( @img, @dm.x_mm, @dm.x_mm + bp_w_mm, @dm.y_mm + @dm.h_mm - bp_off_mm, bp_gap_mm, @style, ConversionBackprint::LENGTHS )

            # page number
            pn = PageNoBackprint.new( @img, @dm.x_mm + @dm.w_mm / 2, @dm.sh_mm - @dm.y_mm, 6, @style_pageno )
              pn.sett( '%s (210 g/m²)' % @i18n.string( 'part_slide' ) )
              @bprints << pn

            # log scales
            strip = create_strip( @dm.x_mm, @dm.y_mm + @dm.h_mm - @dm.cs_mm + ( ( @dm.h_mm - @dm.hs_mm ) / 2 ), @dm.hs_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "B", 0.5 )
                scale.set_params( 2 )
                scale.set_overflow( 4.0 )
                scale.add_constants( )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "CI", 0.33, true )
                scale.set_style( @style_small )
                scale.set_params( 1, true )
                scale.add_constants( )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "C", 0.5, true )
                scale.set_params( 1 )
                scale.set_overflow( 4.0 )
                scale.add_constants( )

            # rest of units conversion scales
            @bprints << ConversionBackprints.new( @img, @dm.x_mm, @dm.x_mm + bp_w_mm, @dm.y_mm + @dm.h_mm - @dm.cs_mm + bp_off_mm, bp_gap_mm, @style, ConversionBackprint::WEIGHTS + ConversionBackprint::AREAS )
            @bprints << ConversionBackprints.new( @img, @dm.x_mm, @dm.x_mm + bp_w_mm, @dm.y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ) - bp_off_mm, bp_gap_mm, @style, ConversionBackprint::VOLUMES )
          end

          if ( ( @layers & LAYER_REVERSE ) != 0 )
            both = ( @layers & LAYER_FACE ) != 0
            y_mm = !both ? @dm.sh_mm - @dm.y_mm - 2 * ( @dm.h_mm - @dm.cs_mm ) : @dm.y_mm
            # number system conversion scale
            strip = create_strip( @dm.x_mm, y_mm + 1.5 * bp_off_mm, 5 * @dm.hu_mm / 4, @dm.w_m_mm + @dm.w_s_mm, @dm.w_l_mm, 0, @dm.w_a_mm )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_HEX, "", 0.5, true )
                scale.set_style( @style_small )
                scale.set_params( 0.0, 256, 1.0, true )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_DEC, "", 0.5 )
                scale.set_style( @style_small )
                scale.set_params( 0.0, 256, 1.0 )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_DEC, "", 0.5, true )
                scale.set_style( @style_small )
                scale.set_params( 0.0, 256, 1.0, true, false )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_OCT, "", 0.5 )
                scale.set_style( @style_small )
                scale.set_params( 0.0, 256, 1.0 )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_OCT, "", 0.5, true )
                scale.set_style( @style_small )
                scale.set_params( 0.0, 256, 1.0, true, false )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_BIN, "", 0.5 )
                scale.set_style( @style_small )
                scale.set_params( 0.0, 256, 1.0 )
            # angles conversion scale
            strip = create_strip( @dm.x_mm, y_mm + @dm.h_mm - @dm.cs_mm + 2 * bp_off_mm + @dm.hu_mm / 6, 10 * @dm.hu_mm / 12, @dm.w_m_mm + @dm.w_s_mm, @dm.w_l_mm, 0, @dm.w_a_mm )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_DEG, "", 0.5, true )
                scale.set_style( @style_small )
                scale.set_params( 0.0, 360, 1.0, true )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_RAD, "", 0.5 )
                scale.set_style( @style_small )
                scale.set_params( 0.0, ( 2 * Math::PI ), 0.05 )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_RAD, "", 0.5, true )
                scale.set_style( @style_small )
                scale.set_params( 0.0, ( 2 * Math::PI ), 0.05, true, false )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::CUST_GRAD, "", 0.5 )
                scale.set_style( @style_small )
                scale.set_params( 0.0, 400, 1 )
          end
        end

        # page number only on transparent elements
        if ( ( @layers & LAYER_TRANSP ) != 0 ) and ( ( @layers & LAYER_FACE ) != 0 )
          # page number
          pn = PageNoBackprint.new( @img, @dm.x_mm + @dm.w_mm / 2, @dm.sh_mm - @dm.y_mm, 6, @style_pageno )
            pn.sett( '%s (%s)' % [ @i18n.string( 'part_transp' ), @i18n.string( 'tracing_paper' ) ] )
            @bprints << pn
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
        if dir == -1 then y_mm -= @dm.cw_mm end
        s_mm = @dm.ct_mm + @dm.b_mm
        b_mm = 15.0 # overlap
        rw_mm = 2 * @dm.ch_mm + b_mm + 2 * s_mm # projected width of rectangle
        x_mm = @dm.x_mm + ( @dm.w_mm - rw_mm ) / 2
        if ( @layers & LAYER_FACE ) != 0
          # instructions
          off = 0.05
          csr = InstructionsBackprint.new( @img, x_mm + rw_mm - @dm.ch_mm + @dm.ch_mm * off, y_mm + @dm.ch_mm * off, @dm.ch_mm * ( 1 - 2 * off ) )
          csr.setw( @dm.cw_mm - @dm.ch_mm * 2 * off )
          csr.render()
          # contour
          @img.pbegin()
            @img.move( x_mm, y_mm )
            @img.rline( x_mm + b_mm + s_mm, y_mm )
            # circular cutout
            @img.arc( x_mm + b_mm + s_mm + @dm.ch_mm, y_mm, 0.75 * @dm.ch_mm, "0,0" )
            @img.rline( x_mm + rw_mm, y_mm )
            @img.rline( x_mm + rw_mm, y_mm + @dm.cw_mm )
            @img.rline( x_mm, y_mm + @dm.cw_mm )
            @img.rline( x_mm, y_mm )
          @img.pend( @style )
          # logo
          logo_w_mm = 17
          logo_h_mm = 18 * logo_w_mm / 15
          @img.import( 'logo.svg', x_mm + b_mm + s_mm + ( @dm.ch_mm + logo_h_mm ) / 2, y_mm + @dm.cw_mm - 1.37 * logo_w_mm, logo_w_mm, logo_h_mm, 90 )
          # mini-scales
          cm = BottomUpCmScale.new( @img, x_mm + b_mm + s_mm + @dm.ch_mm, y_mm + @dm.cw_mm, @dm.cw_mm - 5, 5 )
            cm.style = @style_cursor
            cm.render()
          inch = BottomUpInchScale.new( @img, x_mm + b_mm + s_mm, y_mm + @dm.cw_mm, @dm.cw_mm - 5, 5 )
            inch.style = @style_cursor
            inch.render()
          @img.rectangle( x_mm, y_mm, b_mm, @dm.cw_mm, @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
          if ( @layers & LAYER_REVERSE ) == 0
            # bending edges
            [ b_mm, s_mm, @dm.ch_mm, s_mm ].each do | w |
              x_mm += w
              @img.pline( x_mm, y_mm, x_mm, y_mm + @dm.hint_mm, @style )
              @img.pline( x_mm, y_mm + @dm.cw_mm, x_mm, y_mm + @dm.cw_mm - @dm.hint_mm, @style )
            end
          end
        end
        if ( @layers & LAYER_REVERSE ) != 0
          # reset
          x_mm = @dm.x_mm + ( @dm.w_mm - rw_mm ) / 2
          gy_mm = dir != -1 ? y_mm : y_mm + @dm.cw_mm
          # see-through edge of cursor
          @img.pbegin( )
            @img.move( x_mm + b_mm + s_mm, gy_mm )
            @img.arc( x_mm + b_mm + s_mm + @dm.ch_mm, gy_mm, 0.75 * @dm.ch_mm, dir != -1 ? "0,0" : "0,1" )
            @img.rline( x_mm + b_mm + s_mm + @dm.ch_mm, gy_mm + dir * 16 )
            @img.rline( x_mm + b_mm + s_mm, gy_mm + dir * 16 )
            @img.rline( x_mm + b_mm + s_mm, gy_mm )
          @img.pend( @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
          # invisible part of cursor transparent element
          @img.rectangle( x_mm + b_mm + s_mm, y_mm + ( dir == -1 ? 2 : @dm.cw_mm - 6 ), @dm.ch_mm, 4, @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
          # debug mode bending edges
          [ b_mm, s_mm, @dm.ch_mm, s_mm ].each do | w |
            x_mm += w
            @img.pline( x_mm, y_mm, x_mm, y_mm + @dm.cw_mm, @style, PATTERN_BEND )
          end
        end
      end

      # render strips and edges for cutting/bending
      public
      def render()
        @style_qr = @style[Io::Creat::Slipstick::Entity::QR]
        @style_cursor = @style[Io::Creat::Slipstick::Entity::LOTICK]
        @style = { :stroke_width => 0.1, :stroke => "black", :stroke_cap => "square", :fill => "none" }
        # [stock] lines are intentionally positioned upside down (in landscape)
        if ( @layers & LAYER_STOCK ) != 0
          # both on same sheet?
          rh_mm = @dm.hu_mm + 2 * @dm.t_mm + @dm.h_mm + @dm.hl_mm # height of rectangle
          dir, y_mm = ( @layers & LAYER_FACE ) == 0 ? [ -1, @dm.sh_mm - @dm.y_mm - rh_mm ] : [ 1, @dm.y_mm ]
          if ( @layers & LAYER_REVERSE ) != 0
            # bending guidelines for the stator
            @img.pline( @dm.x_mm, y_mm + @dm.hu_mm, @dm.x_mm + @dm.w_mm, y_mm + @dm.hu_mm, @style, PATTERN_BEND )
            @img.pline( @dm.x_mm, y_mm + ( @dm.hu_mm + @dm.t_mm ), @dm.x_mm + @dm.w_mm, y_mm + ( @dm.hu_mm + @dm.t_mm ), @style, PATTERN_BEND )
            @img.pline( @dm.x_mm, y_mm + ( @dm.hu_mm + @dm.t_mm + @dm.h_mm ), @dm.x_mm + @dm.w_mm, y_mm + ( @dm.hu_mm + @dm.t_mm + @dm.h_mm ), @style, PATTERN_BEND )
            @img.pline( @dm.x_mm, y_mm + ( @dm.hu_mm + 2 * @dm.t_mm + @dm.h_mm ), @dm.x_mm + @dm.w_mm, y_mm + ( @dm.hu_mm + 2 * @dm.t_mm + @dm.h_mm ), @style, PATTERN_BEND )
            # strengthened back glue area
            @img.rectangle( @dm.x_mm, y_mm + @dm.hu_mm + @dm.t_mm, @dm.w_mm, @dm.h_mm, @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
            # transparent window glue area
            @img.rectangle( @dm.x_mm, y_mm + 2, @dm.w_mm, 4, @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
            @img.rectangle( @dm.x_mm, y_mm + rh_mm - 6, @dm.w_mm, 4, @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
          end
          if ( @layers & LAYER_FACE ) != 0
            # cutting guidelines for the stator
            @img.rectangle( @dm.x_mm, y_mm, @dm.w_mm, rh_mm, @style )
            # branding texts
            brand = PageNoBackprint.new( @img, @dm.x_mm + 168, @dm.y_mm + 6, HEIGHT_BRAND, @style_branding )
              brand.sett( BRAND, true )
              brand.render()
            brand = PageNoBackprint.new( @img, @dm.x_mm + 174, @dm.y_mm + 105, HEIGHT_BRAND, @style_branding )
              brand.sett( "%s %s" % [ @i18n.string( 'slide_rule'), MODEL ], true )
              brand.render()
            bottom_off_mm = 15.0
            bottom_mm = @dm.y_mm + bottom_off_mm + @dm.hl_mm + @dm.t_mm
            gr_size_mm = @dm.h_mm - ( 2 * bottom_off_mm )
            # QR code
            # TODO refactor to inherit from Backprint
            qr = Qr.new( @img, 'http://wheel.creat.io/sr', 4, :h, @bp_x_mm, bottom_mm, gr_size_mm, @style_qr )
            @img.rtext( @dm.x_mm + @dm.w_mm - 5, @dm.y_mm + @dm.hl_mm + @dm.t_mm + @dm.h_mm / 2, -90, @version, Io::Creat::svg_dec_style_units( @style_branding, SVG_STYLE_TEXT ) )
          end
          if dir < 0 then rh_mm = 0 end
          render_cursor( y_mm + dir * ( rh_mm + @dm.y_mm ), dir )
        end

        # [slide] element
        if ( ( @layers & LAYER_SLIDE ) != 0 )
          if ( ( @layers & LAYER_REVERSE ) != 0 )
            # cutting guidelines for the slipstick
            both = ( @layers & LAYER_FACE ) != 0
            y_mm = !both ? @dm.sh_mm - @dm.y_mm - 2 * ( @dm.h_mm - @dm.cs_mm ) : @dm.y_mm
            @img.line( 0, y_mm + @dm.cs_mm, @dm.sw_mm, y_mm + @dm.cs_mm, @style )
            @img.pline( 0, y_mm + @dm.h_mm - @dm.cs_mm, @dm.sw_mm, y_mm + @dm.h_mm - @dm.cs_mm, @style, PATTERN_BEND )
            @img.line( 0, y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ), @dm.sw_mm, y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ), @style )
            # debugging mode, outline borders of area visible in the stock
            if not RELEASE
              @img.text( @dm.sw_mm / 2, y_mm + @dm.h_mm - @dm.cs_mm - 4, @version, @style_branding )
            end
            if both
              # power scales side
              @img.line( 0, y_mm + @dm.hu_mm, @dm.sw_mm, y_mm + @dm.hu_mm, @style )
              @img.line( 0, y_mm + @dm.hu_mm + @dm.hs_mm, @dm.sw_mm, y_mm + @dm.hu_mm + @dm.hs_mm, @style )
              # decimal scales side
              @img.line( 0, y_mm + @dm.hu_mm + @dm.h_mm - @dm.cs_mm, @dm.sw_mm, y_mm + @dm.hu_mm + @dm.h_mm - @dm.cs_mm, @style )
              @img.line( 0, y_mm + @dm.hu_mm + @dm.h_mm - @dm.cs_mm + @dm.hs_mm, @dm.sw_mm, y_mm + @dm.hu_mm + @dm.h_mm - @dm.cs_mm + @dm.hs_mm, @style )
            end
          end
          if ( ( @layers & LAYER_FACE ) != 0 )
            brand = PageNoBackprint.new( @img, @dm.sw_mm - 25, @dm.y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ) - 4, HEIGHT_BRAND, @style_branding )
              brand.sett( "%s %s %s" % [ BRAND, @i18n.string( 'slide_rule'), MODEL ], true )
              brand.render()
          end
        end

        # [transparent] elements cutting lines
        if ( ( @layers & LAYER_TRANSP ) != 0 ) and ( ( @layers & LAYER_FACE ) != 0 )
          style = @style.merge( { :stroke_width => @style[:stroke_width] * 2 } )
          # two stock part
          [ @dm.y_mm, @dm.y_mm + @dm.h_mm + 10 ].each do | y_mm |
            @img.line( 0, y_mm, @dm.sw_mm, y_mm, style )
            @img.line( 0, y_mm + @dm.h_mm, @dm.sw_mm, y_mm + @dm.h_mm, style )
            @img.text( @dm.sw_mm / 2, y_mm + @dm.h_mm + 5, "%s W%gmm H%gmm" % [ @i18n.string( 'part_stock' ), @dm.sw_mm, @dm.h_mm ], @style_aux )
            if not RELEASE
              @img.text( @dm.sw_mm / 2, y_mm + @dm.h_mm - 4 , @version, @style_aux )
            end
          end
          # two cursor parts
          y_mm = @dm.y_mm + 2 * @dm.h_mm + 22.5
          [ ( @dm.sw_mm / 4 ) - ( @dm.ch_mm / 2 ), ( 3 * @dm.sw_mm / 4 ) - ( @dm.ch_mm / 2 ) ].each do | x_mm |
            #x_mm = ( @dm.sw_mm - @dm.ch_mm ) / 2
            @img.line( x_mm, y_mm, x_mm - @dm.hint_mm, y_mm, style )
            @img.rtext( x_mm - 2 * @dm.hint_mm, y_mm, -90, '1', @style_aux )
            @img.line( x_mm, y_mm, x_mm, y_mm - @dm.hint_mm, style )
            @img.text( x_mm, y_mm - 2 * @dm.hint_mm, '2', @style_aux )
            @img.line( x_mm + @dm.ch_mm, y_mm, x_mm + @dm.ch_mm + @dm.hint_mm, y_mm, style )
            @img.rtext( x_mm + @dm.ch_mm + 3 * @dm.hint_mm, y_mm, -90, '1', @style_aux )
            @img.line( x_mm + @dm.ch_mm, y_mm, x_mm + @dm.ch_mm, y_mm - @dm.hint_mm, style )
            @img.text( x_mm + @dm.ch_mm, y_mm - 2 * @dm.hint_mm, '3', @style_aux )
            @img.line( x_mm - @dm.hint_mm, y_mm + @dm.cw_mm, x_mm + @dm.ch_mm + @dm.hint_mm, y_mm + @dm.cw_mm, style )
            @img.text( x_mm, y_mm + @dm.cw_mm + 3 * @dm.hint_mm, '2', @style_aux )
            @img.rtext( x_mm - 2 * @dm.hint_mm, y_mm + @dm.cw_mm, -90, '4', @style_aux )
            @img.line( x_mm, y_mm + @dm.cw_mm, x_mm, y_mm + @dm.cw_mm + @dm.hint_mm, style )
            @img.text( x_mm + @dm.ch_mm, y_mm + @dm.cw_mm + 3 * @dm.hint_mm, '3', @style_aux )
            @img.line( x_mm + @dm.ch_mm, y_mm + @dm.cw_mm, x_mm + @dm.ch_mm, y_mm + @dm.cw_mm + @dm.hint_mm, style )
            @img.rtext( x_mm + @dm.ch_mm + 3 * @dm.hint_mm, y_mm + @dm.cw_mm, -90, '4', @style_aux )
            @img.text( x_mm + @dm.ch_mm / 2, y_mm + @dm.cw_mm + 5, "%s W%gmm H%gmm" % [ @i18n.string( 'part_cursor' ), @dm.ch_mm, @dm.cw_mm ], @style_aux )
          end
        end

        # backprints
        @bprints.each do | bp |
          bp.render()
        end

        # strips of scales
        super( true )
        @img.close()
        return @img.output
      end

    end # A

  end # Model
end # Io::Creat::Slipstick

def usage ( )
  $stderr.puts "Usage: #{$0} <style> <lang> <stator|slide|transp> [both|face|reverse]\n\nOutputs SVG for given element and printout side.\n"
  $stderr.puts " style   .. name of the style to use, supported: default, trip"
  $stderr.puts " lang    .. language code for internationalized strings, supported: en, sk"
  $stderr.puts " stator  .. stock element of slide rule (static)"
  $stderr.puts " slide   .. sliding element of slide rule"
  $stderr.puts " transp  .. transparent elements (tracing paper)"
  $stderr.puts " both    .. generate both sides of the printout"
  $stderr.puts " face    .. generate face side of the printout"
  $stderr.puts " reverse .. generate reverse side of the printout"
end

layers = 0
if ARGV.length <= 2
  usage( )
  exit
end

if ARGV.length >= 2
  if ARGV[0] == 'trip'
    style = Io::Creat::Slipstick::Style::TRIP
  elsif ARGV[0] == 'default'
    style = Io::Creat::Slipstick::Style::DEFAULT
  else
    usage
  end
end

if ARGV.length >= 3
  lang = ARGV[1]
  if ARGV[2] == 'stock'
    layers = Io::Creat::Slipstick::Model::A::LAYER_STOCK
  elsif ARGV[2] == 'slide'
    layers = Io::Creat::Slipstick::Model::A::LAYER_SLIDE
  elsif ARGV[2] == 'transp'
    layers = Io::Creat::Slipstick::Model::A::LAYER_TRANSP
  else
    usage
  end
end

if ARGV.length > 3
  if ARGV[3] == 'face'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_FACE
  elsif ARGV[3] == 'reverse'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_REVERSE
  elsif ARGV[3] == 'both'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_FACE | Io::Creat::Slipstick::Model::A::LAYER_REVERSE
  else
    usage
    exit
  end
end


Io::Creat::Slipstick::I18N.instance.load( 'src/model_a.yml', lang )
a = Io::Creat::Slipstick::Model::A.new( layers, style )
puts a.render()

