
# vim: et

require_relative '../../svg/src/style'
require_relative '../constants'

module Io
  module Creat

    # Replaces font family with Iosevka ss11 and updates the letter-spacing.
    SVG_STYLE[:"font-family"] = 'Iosevka'
    SVG_STYLE[:"letter-spacing"] = 0

    module Slipstick

      IOSEVKA = {
        Entity::TICK     => Io::Creat::SVG_STYLE,
        Entity::HITICK   => Io::Creat::SVG_STYLE.merge( { :"font-weight" => 'bold' } ),
        Entity::LOTICK   => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4 } ),
        Entity::LABEL    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :"font-weight" => 'bold' } ),
        Entity::SCALE    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4 } ),
        Entity::CONSTANT => Io::Creat::SVG_STYLE.merge( { :"font-style" => 'oblique', :"font-size" => 2.4, :fill => 'black' } ),
        Entity::UNITS    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :fill => 'black' } ),
        Entity::BRANDING => Io::Creat::SVG_STYLE.merge( { :"text-anchor" => 'middle', :fill => 'black' } ),
        Entity::PAGENO   => Io::Creat::SVG_STYLE.merge( { :"text-anchor" => 'middle', :fill => 'black', :"stroke-width" => 0.22 } ),
        Entity::AUX      => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :"text-anchor" => 'middle' } ),
        Entity::QR       => { :fill => "black", :"stroke-width" => "0.01mm", :stroke => "black" },
      }

      STYLE = IOSEVKA
 
    end # ::Slipstick
  end # ::Creat
end # ::Io

