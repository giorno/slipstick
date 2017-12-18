
# vim: et

require_relative '../../svg/src/style'
require_relative '../constants'

module Io
  module Creat

    # Default style uses Iosevka ss11-variant font-famimly to provide
    # instrument-like L&F.
    SVG_STYLE[:"font-family"] = 'Slipstick Index'
    SVG_STYLE[:"letter-spacing"] = 0
    SVG_STYLE[:"font-weight"] = '300'

    module Slipstick

      DEFAULT = {
        Entity::TICK     => Io::Creat::SVG_STYLE,
        Entity::HITICK   => Io::Creat::SVG_STYLE.merge( { :"font-weight" => '500' } ),
        Entity::LOTICK   => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4 } ),
        Entity::LABEL    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :"font-weight" => '500' } ),
        Entity::SCALE    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4 } ),
        Entity::CONSTANT => Io::Creat::SVG_STYLE.merge( { :"font-style" => 'oblique', :"font-size" => 2.4, :fill => 'black' } ),
        Entity::UNITS    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :fill => 'black' } ),
        Entity::BRANDING => Io::Creat::SVG_STYLE.merge( { :"text-anchor" => 'middle', :fill => 'black', :"font-weight" => '500' } ),
        Entity::PAGENO   => Io::Creat::SVG_STYLE.merge( { :"text-anchor" => 'middle', :fill => 'black', :"stroke-width" => 0.22 } ),
        Entity::AUX      => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :"text-anchor" => 'middle' } ),
        Entity::QR       => { :fill => "black", :"stroke-width" => "0.01mm", :stroke => "black" },
      }

      STYLE = DEFAULT
 
    end # ::Slipstick
  end # ::Creat
end # ::Io

