
# vim: et

require_relative 'backprint'

module Io::Creat::Slipstick::Backprints

  # renders page number like feature on a printout
  class PageNoBackprint < Backprint

    public
    def sett ( text, filled = false )
      @text = text
      @filled = filled
    end

    public
    def render ( )
      raise "sett() was not called" unless not @text.nil?
      fs_mm = @h_mm / ( @filled ? 1 : 1.8 )
      w_mm = ( @text.length + ( @filled ? 2 : 4 ) ) * FONT_WH_RATIO * fs_mm
      line_style = { :fill => ( @filled ? @line_style[:stroke] : 'none' ), :stroke_width => ( @filled ? 'none' : @line_style[:stroke_width] ), :stroke => @line_style[:stroke] }
      text_style = { :font_size => fs_mm, :fill => ( @filled ? 'white' : @line_style[:stroke] ) }
      @img.rectangle( @x_mm - w_mm / 2, @y_mm - @h_mm, w_mm, @h_mm, fs_mm / ( @filled ? 16 : 2 ), @line_style.merge( line_style ) )
      @img.text( @x_mm, @y_mm - ( @filled ? 0.15 : 0.6 ) * fs_mm, @text, @text_style.merge( text_style ) )
    end

  end # PageNoBackprint

end # Io::Creat::Slipstick::Backprints 

