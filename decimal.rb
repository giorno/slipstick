
require 'rasem'

def render ( width_mm, height_mm, count )
  img = Rasem::SVGImage.new( "%dmm" % width_mm, "%dmm" % height_mm ) do
    for i in 1..count
      # next tick
      upper = 10 ** i
      step = upper / 20.0
      for j in 0..17
        x = Math.log10( 10 ** ( i - 1 ) + j * step ) * width_mm / count
        h = height_mm / ( j == 0 ? 1 : ( j % 2 == 0 ? 2 : 4 ) )
        line "%fmm" % x, "0mm", "%fmm" % x, "%fmm" % h
      end
    end
    # last tick
    line "%fmm" % width_mm, "0mm", "%fmm" % width_mm, "%fmm" % height_mm
  end
  puts img.output
end

render( 150, 15, 3 )

