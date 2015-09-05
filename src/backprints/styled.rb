
# vim: et

require_relative '../constants'

module Io::Creat::Slipstick
  module Backprints

    # generate Rasem styles from Slipstick styles
    class Styled

      public
      def initialize ( style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::SCALE] )
        @line_style =  { :stroke => style[:stroke],
                        :stroke_width => style[:stroke_width],
                        :stroke_linecap => "round",
                        :fill => "none" }
        @text_style = { :fill => style[:fill],
                        :font_size => style[:font_size],
                        :font_family => style[:font_family],
                        :font_style => style[:font_style],
                        :letter_spacing => "%gem" % style[:letter_spacing],
                        :text_anchor => "middle" }
      end

    end # Scaled

  end # Backprints
end # Io::Creat::Slipstick

