
# vim: et

require_relative 'trigon'

module Io::Creat::Slipstick::Backprints

  # graphics describing logarithms
  class LogBackprint < TrigonometricBackprint

    def oval ( x_mm, y_mm, w_mm, h_mm, content )
      r_mm = h_mm / 2
      @img.path( @line_style.clone ) do
        moveToA( x_mm - w_mm / 2 + r_mm, y_mm + h_mm )
        arcToA( x_mm - w_mm / 2 + r_mm, y_mm, r_mm, r_mm, 0, 0, 1 )
        lineToA( x_mm + w_mm / 2 - r_mm, y_mm )
        arcToA( x_mm + w_mm / 2 - r_mm, y_mm + h_mm, r_mm, r_mm, 0, 0, 1 )
        lineToA( x_mm - w_mm / 2 + r_mm, y_mm + h_mm )
      end
      @img._text( x_mm, y_mm + 0.75 * h_mm, content, @text_style.merge( { 'text-anchor' => 'middle' } ) )
    end

    def arrow ( x_mm, y_mm, w_mm, h_mm, arrow = nil )
      inv_x = w_mm < 0 ? -1 : 1
      inv_y = h_mm < 0 ? -1 : 1
      dir = 1
      if inv_x * inv_y > 0 then dir = 0 end
      r_mm = @fs_mm / 2
      @img.path( @line_style.clone ) do
        moveToA( x_mm, y_mm )
        lineToA( x_mm, y_mm + ( h_mm - inv_y * r_mm ) )
        arcToA( x_mm + inv_x * r_mm, y_mm + h_mm, r_mm, r_mm, 0, 0, dir )
        lineToA( x_mm + w_mm, y_mm + h_mm )
      end
      if not arrow.nil?
        @img.path( @line_style.merge( { :fill => 'black', :"stroke-linecap" => 'square' } ) ) do
          moveToA( x_mm, y_mm )
          lineToA( x_mm - r_mm / 3, y_mm + inv_y * r_mm )
          lineToA( x_mm + r_mm / 3, y_mm + inv_y * r_mm )
          lineToA( x_mm, y_mm )
        end
      end
    end # arrow

    def render()
      @y_mm -= @h_mm # correct back
      w_mm = getw()
      @img._text( @x_mm, @y_mm + 3 * @fs_mm, "x", @text_style.merge( { 'text-anchor' => 'start' } ) )
      arrow( @x_mm + 0.7 * FONT_WH_RATIO * @fs_mm, @y_mm + 2 * @fs_mm, ( w_mm / 2 ) - 2.7 * FONT_WH_RATIO * @fs_mm, - 1.3 * @fs_mm )
      oval( @x_mm + w_mm / 2, @y_mm, 4 * FONT_WH_RATIO * @fs_mm, 1.4 * @fs_mm, "aˣ" )
      arrow( @x_mm + w_mm - 0.7 * FONT_WH_RATIO * @fs_mm, @y_mm + 2 * @fs_mm, -( ( w_mm / 2 ) - 2.7 * FONT_WH_RATIO * @fs_mm), - 1.3 * @fs_mm, true )
      @img._text( @x_mm + w_mm, @y_mm + 3 * @fs_mm, "y", @text_style.merge( { 'text-anchor' => 'end' } ) )
      arrow( @x_mm + w_mm - 0.7 * FONT_WH_RATIO * @fs_mm, @y_mm + 3.5 * @fs_mm, -( ( w_mm / 2 ) - 4.2 * FONT_WH_RATIO * @fs_mm), 1.2 * @fs_mm )
      oval( @x_mm + w_mm / 2, @y_mm + 4 * @fs_mm, 7 * FONT_WH_RATIO * @fs_mm, 1.4 * @fs_mm, "logₐy" )
      arrow( @x_mm + 0.7 * FONT_WH_RATIO * @fs_mm, @y_mm + 3.5 * @fs_mm, ( w_mm / 2 ) - 4.2 * FONT_WH_RATIO * @fs_mm,  1.2 * @fs_mm, true )

      # logarithmic rules
      [ "log m·n = log m + log n", # product
        "log m/n = log m - log n", # quotient
        "logₙ xⁿ = x",
        "\u00a0log mⁿ = n·log m", # power
        "\u00a0logₐ n = 1/logₙ a", # base switch
        "\u00a0logₐ x = logₙ x/logₙ a", # base change
        "\u00a0logₐ 1 = 0", # log of 1
        "\u00a0logₐ a = 1", # log of base
      ].each_with_index do | rule, index |
        @img._text( @x_mm, @y_mm + ( 7 + index * 1.4 ) * @fs_mm, rule, @text_style.merge( { 'text-anchor' => 'begin' } ) )
      end
    end

    public
    def getw ( )
      return 26.7 * @fs_mm * FONT_WH_RATIO
    end

  end # LogBackprint

end # Io::Creat::Slipstick::Backprints

