
# vim: et

require_relative '../constants'
require_relative 'styled'

module Io::Creat::Slipstick
  module Backprints

    # common properties and functionality of graphical helpers printed on the
    # back of the stock
    class Backprint < Styled

      FONT_WH_RATIO = 0.45 # ratio between Slipstick Sans Mono Regular width and height

      public
      def initialize ( img, x_mm, y_mm, h_mm, style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::SCALE] )
        super( style )
        @img   = img # Svg instance to render on
        @x_mm  = x_mm # left boundary
        @y_mm  = y_mm # top boundary
        @h_mm  = h_mm # backprint height
        # font size for given backprint height
        # other graphics dimensions may be calculated from it
        @fs_mm = @h_mm / ( 5 * 3.5 )
      end

      # returns width after it was calculated
      # used to position the next backprint
      public
      def getw ( )
        return @h_mm # fallback value, assuming square shape
      end

    end # Backprint

  end # Backprints
end # Io::Creat::Slipstick

