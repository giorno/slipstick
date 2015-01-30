
# vim: et

require_relative '../constants'

module Io::Creat::Slipstick
  module Backprints

    # generate Rasem styles from Slipstick styles
    class Styled

      public
      def initialize ( style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::SCALE] )
        @line_style =  { "stroke" => style[Io::Creat::Slipstick::Key::LINE_COLOR],
                        "stroke-width" => style[Io::Creat::Slipstick::Key::LINE_WIDTH],
                        "stroke-linecap" => "round",
                        "fill" => "none" }
        @text_style = { "fill" => style[Io::Creat::Slipstick::Key::FONT_COLOR],
                        "font-size" => style[Io::Creat::Slipstick::Key::FONT_SIZE],
                        "font-family" => style[Io::Creat::Slipstick::Key::FONT_FAMILY],
                        "font-style" => style[Io::Creat::Slipstick::Key::FONT_STYLE],
                        "letter-spacing" => "%gem" % style[Io::Creat::Slipstick::Key::FONT_SPACING],
                        "text-anchor" => "middle" }
      end

    end # Scaled

  end # Backprints
end # Io::Creat::Slipstick

