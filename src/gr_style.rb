
# vim: et

require_relative 'constants'

module Io::Creat::Slipstick
  module Graphics

    class Styled

      # populate Rasem styles from Slipstick styles
      public
      def initialize ( style )
        @line_style =  { "stroke" => style[Io::Creat::Slipstick::Key::LINE_COLOR],
                        "stroke-width" => style[Io::Creat::Slipstick::Key::LINE_WIDTH],
                        "stroke-linecap" => "round",
                        "fill" => "none" }
        @text_style = { "fill" => style[Io::Creat::Slipstick::Key::FONT_COLOR],
                        "font-size" => style[Io::Creat::Slipstick::Key::FONT_SIZE],
                        "font-family" => style[Io::Creat::Slipstick::Key::FONT_FAMILY],
                        "font-style" => style[Io::Creat::Slipstick::Key::FONT_STYLE],
                        "text-anchor" => "middle" }
      end

    end # Style

  end # Graphics
end # Io::Creat::Slipstick

