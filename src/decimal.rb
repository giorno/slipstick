#require 'rasem'

module Io
  module Creat
    module Slipstick

      class DecimalScale

        @@heights = [ 1.0, # major tick (1, 10, 100, 1000, ...)
                      0.8, # minor tick (2, 3, 4, 5, ...)
                      0.7, # middle of minor ticks
                      0.6, 0.45, 0.4 ]

        @@smallest = [ 50.0, 25.0, 10.0, 5.0, 2.0 ] # number of smallest ticks to fill range between major halfs

        @@tick_width = 0.15

        public
        def initialize ( parent, label, width_mm, height_mm, baseline_x_mm, baseline_y_mm, size, align_bottom = false, min_dist_mm = 0.5, font_size_mm = 2.2 )
          @parent        = parent
          @label         = label
          @width_mm      = width_mm
          @height_mm     = height_mm
          @baseline_x_mm = baseline_x_mm
          @baseline_y_mm = baseline_y_mm
          @size          = size
          @align_bottom  = align_bottom
          @min_dist_mm   = min_dist_mm
          @font_size_mm  = font_size_mm
          @constants     = {}
        end

        # these constants will be added as explicit ticks with cursive names when render() is called
        # predefined: Euler's number, Pythagoras' number, square root of 2, Fibonacci's number
        public
        def add_constants ( constants = { "e" => Math::E, "π" => Math::PI, "√2" => Math.sqrt( 2 ), "φ" => 1.61803398874 } )
          @constants = constants
        end

        public
        def add_subscale ( left_border_mm )
          @left_border_mm = left_border_mm
        end

        public
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
              h = @height_mm * ( j == 0 ? @@heights[0] : ( j % 2 == 0 ? @@heights[1] : @@heights[2] ) )
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
                    h = @height_mm * ( k % ( no_smallest / 5 )  == 0 ? @@heights[3] : @@heights[4] )
                    render_tick( mx, h, nil )
                  end
                end
              end
              last = x
            end
          end
          # last tick
          render_tick( @width_mm, @height_mm, "%d" % ( 10 ** @size ) )
          # add constants if any specified
          render_constants()
          render_subscale()
          if not @label.nil?
            img = @parent.instance_variable_get( :@parent ).instance_variable_get( :@img )
            x = @parent.instance_variable_get( :@parent ).instance_variable_get( :@border_x_mm )
            img.text( "%fmm" % x,
                      "%fmm" % ( @baseline_y_mm + ( @align_bottom ? -0.20 : 0.9 ) * @font_size_mm ), # compensation for ignored (by viewers) vertical alignments
                      "%s" % @label,
                      { "fill" => "black",
                        "font-size" => "%fmm" % @font_size_mm,
                        "font-family" => "Arial",
                        "text-anchor" => "left",
                        "font-weight" => "bold" } )
          end
        end

        private
        def render_tick ( x_mm, height_mm, label = nil, bold = true, cursive = false )
          img = @parent.instance_variable_get( :@parent ).instance_variable_get( :@img )
          mult = @align_bottom ? -1 : 1
          img.line( "%fmm" % ( @baseline_x_mm + x_mm ),
                    "%fmm" % @baseline_y_mm,
                    "%fmm" % ( @baseline_x_mm + x_mm ),
                    "%fmm" % ( @baseline_y_mm + mult * height_mm ),
                    { "stroke" => "black",
                      "stroke-width" => "%fmm" % @@tick_width,
                      "stroke-linecap" => "square" } )
          if not label.nil?
            img.text( "%fmm" % ( @baseline_x_mm + x_mm ),
                      "%fmm" % ( mult * height_mm + @baseline_y_mm + ( @align_bottom ? -0.20 : 0.9 ) * @font_size_mm ), # compensation for ignored (by viewers) vertical alignments
                      "%s" % label,
                      { "fill" => "black",
                        "font-size" => "%fmm" % @font_size_mm,
                        "font-family" => "Arial",
                        "font-style" => ( cursive ? "italic" : "normal" ),
                        "text-anchor" => "middle",
                        "dominant-baseline" => "hanging", # seems to be ignored by viewers
                        "font-weight" => bold ? "bold" : "normal" } )
          end
        end

        private
        def render_constants()
          @constants.each do | name, value |
            x = Math.log10( value ) * @width_mm / @size
            h = @height_mm * @@heights[1]
            render_tick( x, h, "%s" % name, false, true )
          end
        end

        # fill range given by border with short scale of log() for values under 1 to the left of the 1 tick
        private
        def render_subscale ( )
          if @left_border_mm.nil?
            return # no data to generate
          end

          value = 1
          last = 0
          step = 0.025
          while true do
            value -= step
            x = Math.log10( value ) * @width_mm / @size
            if x <= 0 - @left_border_mm
              return
            end
            round = ( value * 20 ).round(2) % 2 == 0
            h = @height_mm * ( round ? @@heights[1] : @@heights[2] )
            render_tick( x, h, ( round ? ( "%.1f" % value )[1..-1] : nil ) )

            # filler
            delta = last - x
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
                mx = Math.log10( value + k * stepper ) * @width_mm / @size
                h = @height_mm * ( k % ( no_smallest / 5 )  == 0 ? @@heights[3] : @@heights[4] )
                render_tick( mx, h, nil )
              end
            end
            last = x
          end
        end

      end
    end
  end
end

