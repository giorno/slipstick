
require 'rasem'

def render ( width_mm, height_mm, count )
  # first tick
  puts 0.0
  for i in 0..count
    # next tick
    upper = 10 ** i
    step = upper / 10
    if i > 0
      for j in 1..9
        x = Math.log10( 10 ** ( i - 1 ) + j * step ) * width_mm / count
        puts x
      end
    end
  end
end

render( 150, 15, 3 )

