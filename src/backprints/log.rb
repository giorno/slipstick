
# vim: et

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # graphics describing logarithms
  class LogBackprint < Backprint

    def oval ( x_mm, y_mm, w_mm, h_mm, content )
      r_mm = h_mm / 2
      @img.pbegin()
        @img.move( x_mm - w_mm / 2 + r_mm, y_mm + h_mm )
        @img.arc( x_mm - w_mm / 2 + r_mm, y_mm, r_mm )
        @img.rline( x_mm + w_mm / 2 - r_mm, y_mm )
        @img.arc( x_mm + w_mm / 2 - r_mm, y_mm + h_mm, r_mm )
        @img.rline( x_mm - w_mm / 2 + r_mm, y_mm + h_mm )
      @img.pend( @line_style )
      @img.text( x_mm, y_mm + 0.8 * h_mm, content, @text_style.merge( { 'text-anchor' => 'middle' } ) )
    end

    def render()
      w_mm = @h_mm / 2
      oval( @x_mm + w_mm / 2, @y_mm, 2.6 * @fs_mm, 1.4 * @fs_mm, "aˣ = y \u21d2 logₐy = x" )
      oval( @x_mm + w_mm / 2, @y_mm + 10, 6.6 * @fs_mm, 1.4 * @fs_mm, "logₐy = x" )
    end

  end # LogBackprint

end # Io::Creat::Slipstick::Backprints

