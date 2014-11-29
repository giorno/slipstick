#!/usr/bin/ruby

require 'rasem'

HEIGHTS = [ 1.0, # major tick (1, 10, 100, 1000, ...)
            0.8, # minor tick (2, 3, 4, 5, ...)
            0.7, # middle of minor ticks
            0.6, 0.5, 0.4 ]

class DecimalScale
  @@smallest = [ 10.0, 5.0 ]

  def initialize ( width_mm, height_mm, size, min_dist_mm = 0.8, font_size_mm = 3 )
    @width_mm     = width_mm
    @height_mm    = height_mm
    @size         = size
    @min_dist_mm  = min_dist_mm
    @font_size_mm = font_size_mm

    @img = Rasem::SVGImage.new( "%dmm" % @width_mm, "%dmm" % ( @height_mm + @font_size_mm ) )
  end

  def render ( )
    last = 0
    for i in 1..@size
      # next tick
      upper = 10 ** i
      step = upper / 20.0
      base = 10 ** ( i - 1 ) 
      for j in 0..18
        value = base + j * step
        # physical dimension coordinates
        x = Math.log10( value ) * @width_mm / @size
        h = @height_mm * ( j == 0 ? HEIGHTS[0] : ( j % 2 == 0 ? HEIGHTS[1] : HEIGHTS[2] ) )
        if j < 18 # last one is not rendered, but is required for small ticks calculation
          render_tick( x, h, ( j % 2 ) == 0 ? "%d" % value : nil )
        end

        if j > 0
          # fill the range with smallest ticks
          delta = x - last
          no_smallest = 0
          @@smallest.each do | no |
            if delta > no * @min_dist_mm
              no_smallest = no
              break
            end
          end

          if no_smallest > 0
            stepper = step / no_smallest
            for k in 1..no_smallest - 1
              mx = Math.log10( base + ( j  - 1 ) * step + k * stepper ) * @width_mm / @size
              h = @height_mm * ( k % ( no_smallest / 5 )  == 0 ? HEIGHTS[3] : HEIGHTS[4] )
              render_tick( mx, h, nil )
            end
          end
        end
        last = x
      end
    end
    # last tick
    render_tick( @width_mm, @height_mm, "%d" % ( 10 ** @size ) )
    @img.close
    return @img.output
  end

  private
  def render_tick ( x_mm, height_mm, label = nil, bold = true )
    @img.line( "%fmm" % x_mm, "0mm", "%fmm" % x_mm, "%fmm" % height_mm )
    if not label.nil?
      @img.text( "%fmm" % x_mm,
                 "%fmm" % ( height_mm + @font_size_mm ), # compensation for ignored (by viewers) vertical alignments
                 "%s" % label,
                 { "fill" => "black",
                   "font-size" => "%dmm" % @font_size_mm,
                   "font-family" => "Arial",
                   "text-anchor" => "middle",
                   "dominant-baseline" => "hanging", # seems to be ignored by viewers
                   "font-weight" => bold ? "bold" : "normal" } )
    end
  end
end

dec = DecimalScale.new( 300, 5, 2 )
puts dec.render( )

