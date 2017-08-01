#!/usr/bin/ruby

# vim: et

module Io::Creat::Slipstick
  module Model

    # Static component
    class Stock < Component

      def initialize ( parent, layer )
        super( parent, layer )
        if ( ( @layer & LAYER_FACE ) != 0 )
          # bottom stock strip
          strip = @parent.create_strip( @dm.x_mm, @dm.y_mm, @dm.hl_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
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
          strip = @parent.create_strip( @dm.x_mm, @dm.y_mm + @dm.t_mm + @dm.hl_mm, 8, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "cm", 0.33 )
              scale.set_params( 25 )
              scale.set_overflow( @dm.b_mm )

          # bottom of the stock back
          strip = @parent.create_strip( @dm.x_mm, @dm.y_mm + @dm.t_mm + @dm.h_mm + @dm.hl_mm - 8, 8, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_INCH, "inches", 0.33, true )
              scale.set_params( 10 )
              scale.set_overflow( @dm.b_mm )

          # top stock strip
          strip = @parent.create_strip( @dm.x_mm, @dm.y_mm + 2 * @dm.t_mm + @dm.h_mm + @dm.hu_mm, @dm.hu_mm, @dm.w_m_mm, @dm.w_l_mm, @dm.w_s_mm, @dm.w_a_mm )
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
          bp_border_mm = 12.0
          bp_y_mm = @dm.y_mm + @dm.hl_mm + @dm.t_mm + bp_border_mm
          bp_h_mm = @dm.h_mm - 2 * bp_border_mm
          bp_x_mm = @dm.x_mm + 0.5 * bp_border_mm

          # scales layout
          lo = ScalesBackprint.new( @img, bp_x_mm, bp_y_mm, bp_h_mm )
            @bprints << lo
            bp_x_mm += bp_border_mm / 2 + lo.getw()

          # sin-cos help
          gr = TrigonometricBackprint.new( @img, bp_x_mm, bp_y_mm, bp_h_mm )
            @bprints << gr
            bp_x_mm += bp_border_mm / 2 + gr.getw()

          # log help
          gr = LogBackprint.new( @img, bp_x_mm, bp_y_mm, bp_h_mm )
            @bprints << gr
            bp_x_mm += bp_border_mm / 2 + gr.getw()

          # table of mathematical and physical constants
          cbp = ConstantsBackprint.new( @img, bp_x_mm, bp_y_mm, bp_h_mm )
            @bprints << cbp
            bp_x_mm += bp_border_mm / 2 + cbp.getw()

          # QR code
          bottom_off_mm = 15.0
          bottom_mm = @dm.y_mm + bottom_off_mm + @dm.hl_mm + @dm.t_mm
          gr_size_mm = @dm.h_mm - ( 2 * bottom_off_mm )
          qr = Qr.new( @img, 'http://wheel.creat.io/sr', 4, :h, bp_x_mm, bottom_mm, gr_size_mm, @style[Io::Creat::Slipstick::Entity::QR] )
            @bprints << qr

          # page number
          pn = PageNoBackprint.new( @img, @dm.x_mm + @dm.w_mm / 2, @dm.sh_mm - @dm.y_mm, 6, @style_pageno )
            pn.sett( '%s + %s (210 g/m²)' % [ @i18n.string( 'part_stock' ), @i18n.string( 'part_cursor' )  ] )
            @bprints << pn
        end
      end # initialize

      def render ( )
        # [stock] lines are intentionally positioned upside down (in landscape)
        # both on same sheet?
        rh_mm = @dm.hu_mm + 2 * @dm.t_mm + @dm.h_mm + @dm.hl_mm # height of rectangle
        dir, y_mm = ( @layer & Component::LAYER_FACE ) == 0 ? [ -1, @dm.sh_mm - @dm.y_mm - rh_mm ] : [ 1, @dm.y_mm ]
        if ( @layer & Component::LAYER_REVERSE ) != 0
          # bending guidelines for the stator
          @img.pline( @dm.x_mm, y_mm + @dm.hu_mm, @dm.x_mm + @dm.w_mm, y_mm + @dm.hu_mm, @style_contours, @branding.pattern )
          @img.pline( @dm.x_mm, y_mm + ( @dm.hu_mm + @dm.t_mm ), @dm.x_mm + @dm.w_mm, y_mm + ( @dm.hu_mm + @dm.t_mm ), @style_contours, @branding.pattern )
          @img.pline( @dm.x_mm, y_mm + ( @dm.hu_mm + @dm.t_mm + @dm.h_mm ), @dm.x_mm + @dm.w_mm, y_mm + ( @dm.hu_mm + @dm.t_mm + @dm.h_mm ), @style_contours, @branding.pattern )
          @img.pline( @dm.x_mm, y_mm + ( @dm.hu_mm + 2 * @dm.t_mm + @dm.h_mm ), @dm.x_mm + @dm.w_mm, y_mm + ( @dm.hu_mm + 2 * @dm.t_mm + @dm.h_mm ), @style_contours, @branding.pattern )
          # strengthened back glue area
          @img.rectangle( @dm.x_mm, y_mm + @dm.hu_mm + @dm.t_mm, @dm.w_mm, @dm.h_mm, @style_contours.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
          # transparent window glue area
          @img.rectangle( @dm.x_mm, y_mm + 2, @dm.w_mm, 4, @style_contours.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
          @img.rectangle( @dm.x_mm, y_mm + rh_mm - 6, @dm.w_mm, 4, @style_contours.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) )
        end
        if ( @layer & Component::LAYER_FACE ) != 0
          # cutting guidelines for the stator
          @img.rectangle @dm.x_mm, y_mm, @dm.w_mm, rh_mm, @style_contours
          # branding texts
          brand = PageNoBackprint.new( @img, @dm.x_mm + 168, @dm.y_mm + 6, @branding.height, @style_branding )
            brand.sett( @branding.brand, true )
            brand.render()
          brand = PageNoBackprint.new( @img, @dm.x_mm + 174, @dm.y_mm + 105, @branding.height, @style_branding )
            brand.sett( "%s %s" % [ @i18n.string( 'slide_rule'), @branding.model ], true )
            brand.render()
          @img._rtext( @dm.x_mm + @dm.w_mm - 5, @dm.y_mm + @dm.hl_mm + @dm.t_mm + @dm.h_mm / 2, -90, @branding.version, Io::Creat::svg_dec_style_units( @style_branding, SVG_STYLE_TEXT ) )
          # bending hints for the stator on the face side
          y = y_mm
          [ 0, @dm.hu_mm, @dm.t_mm, @dm.h_mm, @dm.t_mm].each do |increment|
            y += increment
            @img.pline( @dm.x_mm, y, @dm.x_mm + @dm.hint_mm, y, @style_contours )
            @img.pline( @dm.x_mm + @dm.w_mm, y, @dm.x_mm + @dm.w_mm - @dm.hint_mm, y, @style_contours )
          end
        end
        if dir < 0 then rh_mm = 0 end
        @parent.render_cursor( y_mm + dir * ( rh_mm + @dm.y_mm ), dir )

        super()
      end # render

    end # Stock

  end # Model

end # Io::Creat::Slipstick

