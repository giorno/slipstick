#!/usr/bin/ruby

# vim: et

require_relative 'backprints/dof'
require_relative 'model_a_slide'

module Io::Creat::Slipstick
  module Model

    # Sliding component for photographic calculations
    class PhotoSlide < Slide

      public
      def initialize ( parent, layer )
        super( parent, layer )
        if ( ( @layer & LAYER_FACE ) != 0 )

          # photo scales
          ll_off_mm = 4
          strip = @parent.create_strip( @dm.x_mm, @dm.y_mm + @dm.h_mm - @dm.cs_mm + ( ( @dm.h_mm - @dm.hs_mm ) / 2 ), @dm.hs_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::PHOTO_HFD, "Nikon DX 19μm", 0.5 )
              scale.set_params( 0.019 )
              scale.set_overflow( 4.0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::PHOTO_HFD, "APS-C Canon 18μm", 0.33 )
              scale.set_params( 0.018 )
              scale.set_style( @style_small )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::PHOTO_HFD, "35mm 29μm", 0.5, true )
              scale.set_params( 0.029 )
              scale.set_overflow( 4.0 )

          # page number
          pn = PageNoBackprint.new( @img, @dm.x_mm + @dm.w_mm / 2, @dm.sh_mm - @dm.y_mm, 6, @style_pageno )
            pn.sett( '%s (210 g/m²)' % @i18n.string( 'part_slide_photo' ) )
            @bprints << pn

          brand = PageNoBackprint.new( @img, @dm.sw_mm - 25, @dm.y_mm + 2 * ( @dm.h_mm - @dm.cs_mm ) - 4, @branding.height, @style_branding )
            brand.sett( "%s %s %s-P" % [ @branding.brand, @i18n.string( 'part_slide_photo'), @branding.model ], true )
            @bprints << brand

          @bprints << DepthOfFieldBackprint.new( @img, @dm.x_mm + 5, @dm.y_mm + @dm.cs_mm + @dm.x_mm - 2, @dm.sw_mm - 2 * @dm.x_mm - 5, @dm.h_mm - @dm.cs_mm - 2 * @dm.x_mm + 2, @style_small )
        end
        if ( ( @layer & LAYER_REVERSE ) != 0 )

          # log scales
          strip = @parent.create_strip( @dm.x_mm, @dm.sh_mm - @dm.y_mm - 2 * ( @dm.h_mm - @dm.cs_mm ) + ( ( @dm.h_mm - @dm.hs_mm ) / 2 ), @dm.hs_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
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

          # power scales
          ll_off_mm = 4
          strip = @parent.create_strip( @dm.x_mm, @dm.sh_mm - @dm.y_mm - ( @dm.h_mm - @dm.cs_mm ) + ( ( @dm.h_mm - @dm.hs_mm ) / 2 ), @dm.hs_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm - ll_off_mm, @dm.w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "LL1", 0.5 )
              scale.set_params( 100 )
              scale.set_overflow( 4.0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "LL2", 0.33, true )
              scale.set_style( @style_small )
              scale.set_params( 10 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "LL3", 0.5, true )
              scale.set_params( 1 )
              scale.set_overflow( 4.0 )

        end
      end # initialize

      def render ( )
        super()
	# render vertical lines for hyperfocal distance result calculation,
	# corresponding to values 1 and 10 on C/D scales
        if ( ( @layer & Component::LAYER_FACE ) != 0 )
	  [ @dm.x_mm + @dm.w_l_mm + @dm.w_s_mm, @dm.x_mm + @dm.w_l_mm + @dm.w_s_mm + @dm.w_m_mm ].each do | x_mm |
            y1_mm = @dm.y_mm + @dm.h_mm - @dm.cs_mm + @dm.h_mm / 2 - 5
            @img.line( x_mm, y1_mm, x_mm, @dm.y_mm + @dm.h_mm - @dm.cs_mm + ( ( @dm.h_mm - @dm.hs_mm ) / 2 ) - 4, @style_contours )
            @img._text( x_mm, y1_mm + 3, 'H', @style_aux )
	  end
        end

        super()
      end # render

    end # Slide

  end # Model

end # Io::Creat::Slipstick

