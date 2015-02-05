
# vim: et

require_relative 'trigon'

module Io::Creat::Slipstick::Backprints

  # graphics describing logarithms
  class LogBackprint < TrigonometricBackprint

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

    def arrow ( x_mm, y_mm, w_mm, h_mm, arrow = nil )
      inv_x = w_mm < 0 ? -1 : 1
      inv_y = h_mm < 0 ? -1 : 1
      dir = "0,1"
      if inv_x * inv_y > 0 then dir = "0,0" end
      r_mm = @fs_mm / 2
      @img.pbegin()
        @img.move( x_mm, y_mm )
        @img.rline( x_mm, y_mm + ( h_mm - inv_y * r_mm ) )
        @img.arc( x_mm + inv_x * r_mm, y_mm + h_mm, r_mm, dir )
        @img.rline( x_mm + w_mm, y_mm + h_mm )
      @img.pend( @line_style )
      if not arrow.nil?
        @img.pbeing()
        @img.pend( @line_style )
      end
    end

    def render()
      w_mm = @h_mm / 2
      @img.text( @x_mm, @y_mm + 3 * @fs_mm, "x", @text_style.merge( { 'text-anchor' => 'start' } ) )
      arrow( @x_mm + 0.7 * FONT_WH_RATIO * @fs_mm, @y_mm + 2 * @fs_mm, ( w_mm / 2 ) - 2.7 * FONT_WH_RATIO * @fs_mm, - 1.3 * @fs_mm )
      oval( @x_mm + w_mm / 2, @y_mm, 4 * FONT_WH_RATIO * @fs_mm, 1.4 * @fs_mm, "aˣ" )
      arrow( @x_mm + w_mm - 0.7 * FONT_WH_RATIO * @fs_mm, @y_mm + 2 * @fs_mm, -( ( w_mm / 2 ) - 2.7 * FONT_WH_RATIO * @fs_mm), - 1.3 * @fs_mm )
      @img.text( @x_mm + w_mm, @y_mm + 3 * @fs_mm, "y", @text_style.merge( { 'text-anchor' => 'end' } ) )
      arrow( @x_mm + w_mm - 0.7 * FONT_WH_RATIO * @fs_mm, @y_mm + 3.5 * @fs_mm, -( ( w_mm / 2 ) - 4.2 * FONT_WH_RATIO * @fs_mm), 1.2 * @fs_mm )
      oval( @x_mm + w_mm / 2, @y_mm + 4 * @fs_mm, 7 * FONT_WH_RATIO * @fs_mm, 1.4 * @fs_mm, "logₐy" )
      arrow( @x_mm + 0.7 * FONT_WH_RATIO * @fs_mm, @y_mm + 3.5 * @fs_mm, ( w_mm / 2 ) - 4.2 * FONT_WH_RATIO * @fs_mm,  1.2 * @fs_mm )
    end

  end # LogBackprint

end # Io::Creat::Slipstick::Backprints
