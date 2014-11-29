#!/usr/bin/ruby

require 'rasem'

HEIGHTS = [ 1.0, # major tick (1, 10, 100, 1000, ...)
            0.8, # minor tick (2, 3, 4, 5, ...)
            0.7, # middle of minor ticks
            0.6, 0.5, 0.4 ]

def render ( width_mm, height_mm, count, min = 0.8, font_size_mm = 3 )
  img = Rasem::SVGImage.new( "%dmm" % width_mm, "%dmm" % ( height_mm + font_size_mm ) ) do
    last = 0
    for i in 1..count
      # next tick
      upper = 10 ** i
      step = upper / 20.0
      base = 10 ** ( i - 1 ) 
      for j in 0..18
        x = Math.log10( base + j * step ) * width_mm / count
        h = height_mm * ( j == 0 ? HEIGHTS[0] : ( j % 2 == 0 ? HEIGHTS[1] : HEIGHTS[2] ) )
        if j < 18 # calculated values are needed for smaller ticks, but lines should not be generated
          line "%fmm" % x, "0mm", "%fmm" % x, "%fmm" % h
          if ( j % 2 ) == 0
            text "%fmm" % x, "%fmm" % ( h + 3 ), "%d" % (base + j * step), { "fill" => "black", "font-size" => "3mm",  "font-family" => "Arial", "text-anchor" => "middle", "dominant-baseline" => "hanging", "font-weight" => "bold" }
          end
          #text 0, 0, "aaa"
        end

        if j > 0
          # fill the range with smallest ticks
          #$stderr.puts x - last
          if x - last > 10.0 * min
            fillers = 10.0
          elsif x - last > 5.0 * min
            fillers = 5.0
          #elsif x - last > 2.0 * min
          #  fillers = 2.0
          else
            fillers = 0.0
          end

          if fillers > 0
            stepper = ( step ) / fillers
            #$stderr.puts stepper
            for k in 1..fillers - 1
              #$stderr.puts base + ( k - 1 ) * step + k * stepper
              mx = Math.log10( base + ( j  - 1 ) * step + k * stepper ) * width_mm / count#( x - last )
              h = height_mm * ( k % ( fillers / 5 )  == 0 ? HEIGHTS[3] : HEIGHTS[4] )
              line "%fmm" % mx, "0mm", "%fmm" % mx, "%fmm" % h
            end
          end
        end
        last = x
      end
    end
    # last tick
    line "%fmm" % width_mm, "0mm", "%fmm" % width_mm, "%fmm" % height_mm
  end
  puts img.output
end

render( 300, 10, 2 )

