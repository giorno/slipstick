
require_relative 'backprint'
require_relative '../constants'

module Io::Creat::Slipstick::Backprints

  # common functionality of small scales rendered on the front of the cursor
  class BottomUpLinearScale

    def initialize ( img, x_mm, y_mm, l_mm, h_mm, style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::TICK] )
      @img   = img
      @x_mm  = x_mm
      @y_mm  = y_mm
      @l_mm  = l_mm # length of scale
      @h_mm  = h_mm # tick line height
      @style = style
    end

    def setparams ( step, fodders, l2r = false, scale = 10, suffix = '' )
      @step    = step
      @fodders = fodders
      @l2r     = l2r
      @scale   = scale
      @suffix  = suffix
    end

    def render ( )
      raise "setparam() not called" unless not @step.nil? and not @fodders.nil?
      rl_mm = 0 # relative distance from zero
      while ( rl_mm * @scale < @l_mm ) do
        h_idx = 0 # height index
        @fodders.each do | mod, idx |
          h_idx = idx
          if rl_mm.round( 4 ) % mod == 0
            break
          end
        end

        label = ( h_idx == 0 and rl_mm > 0.0 ) ? '%d' % ( rl_mm ).round() : nil
        render_tick( @y_mm - rl_mm * @scale, @h_mm * Io::Creat::Slipstick::Dim::DEFAULT[Io::Creat::Slipstick::Key::TICK_HEIGHT][h_idx], label )
        rl_mm += @step
      end
    end

    def render_tick ( y_mm, h_mm, label = nil )
      @img.line( @x_mm + ( @l2r ? 1 : -1 ) * h_mm,
                 y_mm,
                 @x_mm,
                 y_mm,
                 { :stroke => @style[Io::Creat::Slipstick::Key::LINE_COLOR],
                   :stroke_width => @style[Io::Creat::Slipstick::Key::LINE_WIDTH],
                   :stroke_linecap => 'butt' } )

      if label.nil? then return end
      for space in 0..@suffix.length do
        label = "\u00a0" + label
      end
      label = label + ' ' + @suffix
      @img.rtext( @x_mm + ( @l2r ? 1 + h_mm : - h_mm - @style[Io::Creat::Slipstick::Key::FONT_SIZE] ),
                  y_mm,
                  90,
                  label,
                  { :fill => @style[Io::Creat::Slipstick::Key::FONT_COLOR],
                    :font_size => "%f" % @style[Io::Creat::Slipstick::Key::FONT_SIZE],
                    :font_family => @style[Io::Creat::Slipstick::Key::FONT_FAMILY],
                    :font_style => @style[Io::Creat::Slipstick::Key::FONT_STYLE],
                    :text_anchor => "middle",
                    :letter_spacing => "%gem" % @style[Io::Creat::Slipstick::Key::FONT_SPACING],
                    :font_weight => @style[Io::Creat::Slipstick::Key::FONT_WEIGHT] } )
    end
  
  end # BottomUpLinearScale

  class BottomUpCmScale < BottomUpLinearScale
    FODDERS = { 1.0 => 0, 0.5 => 2, 0.1 => 3 }

    def initialize ( img, x_mm, y_mm, l_mm, h_mm )
      super( img, x_mm, y_mm, l_mm, h_mm )
      setparams( 0.1, FODDERS, false, 10, 'cm' )
    end

  end # BottomUpLinearScale

  class BottomUpInchScale < BottomUpLinearScale
    FODDERS = { 1.0 => 0, 0.5 => 2, 0.25 => 3, 0.125 => 4, 0.0625 => 5 }

    def initialize ( img, x_mm, y_mm, l_mm, h_mm )
      super( img, x_mm, y_mm, l_mm, h_mm )
      setparams( 0.0625, FODDERS, true, 25.4, 'inch' )
    end

  end # BottomUpInchScale

end # Io::Creat::Slipstick::Backprints

