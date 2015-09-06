
# vim: et

require_relative '../constants'

module Io::Creat::Slipstick
  module Backprints

    # generate Rasem styles from Slipstick styles
    class Styled

      public
      def initialize ( style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::SCALE] )
        @line_style = style.merge( { :stroke_linecap => 'round', :fill => 'none' } )
        @text_style = Io::Creat::svg_dec_style_units( style.merge( { :text_anchor => 'middle' } ), Io::Creat::SVG_STYLE_TEXT )
      end

    end # Scaled

  end # Backprints
end # Io::Creat::Slipstick

