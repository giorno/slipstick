
# vim: et

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # renders page number like feature on a printout
  class PageNoBackprint < Backprint

    public
    def sett ( text ) @text = text end

    public
    def render ( )
      raise "sett() was not called" unless not @text.nil?
      fs_mm = @h_mm / 1.8
      w_mm = ( @text.length + 4 ) * FONT_WH_RATIO * fs_mm
      @img.rectangle( @x_mm - w_mm / 2, @y_mm - @h_mm, w_mm, @h_mm, fs_mm / 2, @line_style.merge( { 'fill' => 'none', 'stroke-width' => @line_style['stroke-width'] * 2 } ) )
      @img.text( @x_mm, @y_mm - 0.6 * fs_mm, @text, @text_style.merge( { 'font-size' => fs_mm, 'fill' => 'black' } ) )
    end

  end # PageNoBackprint

end # Io::Creat::Slipstick::Backprints 

