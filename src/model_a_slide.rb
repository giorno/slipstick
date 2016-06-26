#!/usr/bin/ruby

# vim: et

module Io::Creat::Slipstick
  module Model

    # Sliding component
    class Slide < Component

      public
      def initialize ( parent, layer )
        super( parent, layer )
        bp_off_mm = 9 # offset of conversion scales from the edge of slide
          if ( ( @layer & LAYER_FACE ) != 0 )

            # temperature conversion scale
            strip = @parent.create_strip( @dm.x_mm, @dm.y_mm + bp_off_mm - @dm.hu_mm / 4 , @dm.hu_mm / 2, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_TEMP, "°C", 0.5, true )
                scale.set_style( @style_units )
                scale.set_params( -50.0, 200.0, 1.0, true )
              scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_TEMP, "°F", 0.5 )
                scale.set_style( @style_units )
                scale.set_params( -58.0, 392.0, 1.0 )

            # power scales
            ll_off_mm = 4 # shift LL scales to the left to make room for the last (too wide) tick label
            strip = @parent.create_strip( @dm.x_mm, @dm.y_mm + ( ( @dm.h_mm - @dm.hs_mm ) / 2 ), @dm.hs_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm - ll_off_mm, @dm.w_a_mm )
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
            strip = @parent.create_strip( @dm.x_mm, @dm.y_mm + @dm.h_mm - @dm.cs_mm + ( ( @dm.h_mm - @dm.hs_mm ) / 2 ), @dm.hs_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
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

          if ( ( @layer & LAYER_REVERSE ) != 0 )
            both = ( @layer & LAYER_FACE ) != 0
            y_mm = !both ? @dm.sh_mm - @dm.y_mm - 2 * ( @dm.h_mm - @dm.cs_mm ) : @dm.y_mm
            # number system conversion scale
            strip = @parent.create_strip( @dm.x_mm, y_mm + 1.5 * bp_off_mm, 5 * @dm.hu_mm / 4, @dm.w_m_mm + @dm.w_s_mm, @dm.w_l_mm, 0, @dm.w_a_mm )
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
            strip = @parent.create_strip( @dm.x_mm, y_mm + @dm.h_mm - @dm.cs_mm + 2 * bp_off_mm + @dm.hu_mm / 6, 10 * @dm.hu_mm / 12, @dm.w_m_mm + @dm.w_s_mm, @dm.w_l_mm, 0, @dm.w_a_mm )
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
      end # initialize

      def render ( )
        @style = { :stroke_width => 0.1, :stroke => "black", :stroke_cap => "square", :fill => "none" }
          if ( ( @layer & Component::LAYER_REVERSE ) != 0 )
            # cutting guidelines for the slipstick
            both = ( @layer & Component::LAYER_FACE ) != 0
            y_mm = !both ? @dm.sh_mm - @dm.y_mm - 2 * ( @dm.h_mm - @dm.cs_mm ) : @dm.y_mm
            @img.line( 0, y_mm + @dm.cs_mm, @dm.sw_mm, y_mm + @dm.cs_mm, @style )
            @img.pline( 0, y_mm + @dm.h_mm - @dm.cs_mm, @dm.sw_mm, y_mm + @dm.h_mm - @dm.cs_mm, @style, @branding.pattern )
            @img.line( 0, y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ), @dm.sw_mm, y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ), @style )
            # debugging mode, outline borders of area visible in the stock
            if not @branding.release
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
          if ( ( @layer & Component::LAYER_FACE ) != 0 )
            brand = PageNoBackprint.new( @img, @dm.sw_mm - 25, @dm.y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ) - 4, @branding.height, @style_branding )
              brand.sett( "%s %s %s" % [ @branding.brand, @i18n.string( 'slide_rule'), @branding.model ], true )
              brand.render()
          end
        super()
      end # render

    end # Slide

  end # Model

end # Io::Creat::Slipstick

