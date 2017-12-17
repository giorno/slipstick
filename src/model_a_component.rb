#!/usr/bin/ruby

# vim: et

module Io::Creat::Slipstick
  module Model

    # Branding information content and rendering
    class Branding
      attr_accessor :version, :release, :brand, :model, :height, :pattern
    end # Branding

    # Crete pattern for communicating model dimensions to the components
    class Dimensions
      attr_accessor :hu_mm, :hl_mm, :hs_mm, :t_mm, :sh_mm, :sw_mm, :h_mm,
                    :x_mm, :y_mm, :w_mm, :b_mm, :ct_mm, :cc_mm, :cs_mm,
                    :cw_mm, :ch_mm, :hint_mm, :w_m_mm, :w_l_mm, :w_s_mm,
                    :w_a_mm, :sc_mm

      def initialize( h_mm, w_mm )
        @hu_mm = 22.0 # height of upper half of stator strip
        @hl_mm = 22.0 # height of lower half of stator strip
        @hs_mm = 18.0 # height of slipstick strip
        @t_mm  = 0.0#1.5 # thickness of the slipstick
        @sc_mm = 2.0 # compensation of the stock height
        @sh_mm = h_mm # sheet height
        @sw_mm = w_mm # sheet width
        @h_mm  = @hu_mm + @hl_mm + @hs_mm
        @x_mm  = 5.0
        @y_mm  = 10.0
        @w_mm  = 287.0
        @b_mm  = 0.1 # bending radius (approximated)
        @ct_mm = 1.0 # thickness of cursor
        @cc_mm = 0#1.5 # compensation to add to cursor height
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

      public
      def initialize ( parent, layer )
        raise "Face must be either LAYER_FACE or LAYER_REVERSE" unless ( [ LAYER_FACE, LAYER_REVERSE, LAYER_FACE | LAYER_REVERSE ].include?( layer ) )
        @parent = parent
        @img = @parent.img
        @dm = @parent.dm # instance of class Dimensions
        @style = @parent.style
        @i18n = @parent.i18n
        @branding = @parent.branding
        @layer = layer

        @bprints = [] # each component maintains its own backprints

        # prepare style for smaller scales
        @style_small = @style.merge( { Io::Creat::Slipstick::Entity::TICK => @style[Io::Creat::Slipstick::Entity::LOTICK] } )
        @style_units = @style.merge( { Io::Creat::Slipstick::Entity::TICK => @style[Io::Creat::Slipstick::Entity::UNITS] } )
        @style_branding = @style[Io::Creat::Slipstick::Entity::BRANDING]
        @style_pageno = @style[Io::Creat::Slipstick::Entity::PAGENO]
        @style_aux = Io::Creat::svg_dec_style_units( @style[Io::Creat::Slipstick::Entity::AUX], SVG_STYLE_TEXT )
        @style_contours = { :"stroke-width" => 0.1, :stroke => "black", :"stroke-linecap" => "square", :fill => "none" }

      end # initialize

      # expected to be called from subclass.render()
      def render ( )
        @bprints.each do | bp |
          bp.render()
        end
      end # render

    end # Component

  end # Model

end # Io::Creat::Slipstick

