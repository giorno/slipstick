#!/usr/bin/ruby

# vim: et

module Io::Creat::Slipstick
  module Model

    # Transparent parts
    class Transparent < Component

      public
      def initialize ( parent, layer )
        super( parent, layer )
        # page number only on transparent elements
        if ( ( @layer & Component::LAYER_FACE ) != 0 )
          # page number
          pn = PageNoBackprint.new( @img, @dm.x_mm + @dm.w_mm / 2, @dm.sh_mm - @dm.y_mm, 6, @style_pageno )
            pn.sett( '%s (%s)' % [ @i18n.string( 'part_transp' ), @i18n.string( 'tracing_paper' ) ] )
            @bprints << pn
        end
      end # initialize

    end # Transparent

  end # Model

end # Io::Creat::Slipstick

