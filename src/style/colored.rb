
# vim: et

require_relative '../../svg/src/style'
require_relative '../constants'

module Io
  module Creat
    module Slipstick

      # derivation of the default style applying colors to more defined features
      COLORED = {
        Entity::TICK     => Io::Creat::SVG_STYLE,
        Entity::HITICK   => Io::Creat::SVG_STYLE.merge( { :"font-weight" => 'bold', :fill => '#ff6f00' } ),
        Entity::LOTICK   => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4 } ),
        Entity::LABEL    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :fill => '#971c1c', :"font-weight" => 'bold', :"letter-spacing" => -0.10 } ),
        Entity::SCALE    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :"letter-spacing" => -0.10 } ),
        Entity::CONSTANT => Io::Creat::SVG_STYLE.merge( { :"font-style" => 'oblique', :"font-size" => 2.4, :fill => '#283593', :stroke => '#283593' } ),
        Entity::UNITS    => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :fill => '#878787', :stroke => '#878787' } ),
        Entity::BRANDING => Io::Creat::SVG_STYLE.merge( { :"text-anchor" => 'middle', :stroke => '#971c1c', :"letter-spacing" => -0.10 } ),
        Entity::PAGENO   => Io::Creat::SVG_STYLE.merge( { :"text-anchor" => 'middle', :fill => 'black', :"stroke-width" => 0.22 } ),
        Entity::AUX      => Io::Creat::SVG_STYLE.merge( { :"font-size" => 2.4, :"text-anchor" => 'middle', :"letter-spacing" => 0 } ),
        Entity::QR       => { :fill => "black", :"stroke-width" => "0.01mm", :stroke => "black" },
      }

      STYLE = COLORED
 
    end # ::Slipstick
  end # ::Creat
end # ::Io

