#!/usr/bin/ruby

require 'rasem'

class DecimalScale

  @@heights = [ 1.0, # major tick (1, 10, 100, 1000, ...)
                0.8, # minor tick (2, 3, 4, 5, ...)
                0.7, # middle of minor ticks
                0.6, 0.45, 0.4 ]

  @@smallest = [ 50.0, 25.0, 10.0, 5.0, 2.0 ] # number of smallest ticks to fill range between major halfs

  @@tick_width = 0.15

  public
  def initialize ( parent, width_mm, height_mm, baseline_x_mm, baseline_y_mm, size, align_bottom = false, min_dist_mm = 0.8, font_size_mm = 2.8 )
    @parent        = parent
    @width_mm      = width_mm
    @height_mm     = height_mm
    @baseline_x_mm = baseline_x_mm
    @baseline_y_mm = baseline_y_mm
    @size          = size
    @align_bottom  = align_bottom
    @min_dist_mm   = min_dist_mm
    @font_size_mm  = font_size_mm
    @constants     = {}

    #@img = Rasem::SVGImage.new( "%dmm" % @width_mm, "%dmm" % ( @height_mm + @font_size_mm ) )
  end

  # these constants will be added as explicit ticks with cursive names when render() is called
  # predefined: Euler's number, Pythagoras' number, square root of 2, Fibonacci's number
  public
  def add_constants( constants = { "e" => Math::E, "π" => Math::PI, "√2" => Math.sqrt( 2 ), "φ" => 1.61803398874 } )
    @constants = constants
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

    #@img.close
    #return @img.output
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
                "%fmm" % ( mult * height_mm + @baseline_y_mm + ( @align_bottom ? 0 : @font_size_mm ) ), # compensation for ignored (by viewers) vertical alignments
                "%s" % label,
                { "fill" => "black",
                  "font-size" => "%dmm" % @font_size_mm,
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
end

# a collection of Scales serving as a sliding strip
class Strip

  def initialize ( parent, width_mm, height_mm, offset_x_mm, offset_y_mm, scale_height_mm )
    @parent          = parent
    @width_mm        = width_mm
    @height_mm       = height_mm
    @offset_x_mm     = offset_x_mm
    @offset_y_mm     = offset_y_mm
    @scale_height_mm = scale_height_mm
    @scales          = []
  end

  # align_bottom if true, lines are aligned to the bottom
  def create_scale ( size, baseline_x_mm = 0, baseline_y_mm = 0, align_bottom = false  )
    scale = DecimalScale.new( self, @width_mm - baseline_x_mm, @scale_height_mm, @offset_x_mm + baseline_x_mm, @offset_y_mm + baseline_y_mm, size, align_bottom )
    @scales << scale
    return scale
  end

  def render ( )
    @scales.each do | scale |
      scale.render()
    end
  end
end

# a vertical layout of Strips to be printed and cut out
class Sheet
  # by default initialized to landscape A4 format with 5mm borders
  def initialize ( width_mm = 297, height_mm = 210, border_x_mm = 5, border_y_mm = nil, spacing_y_mm = nil )
    @width_mm     = width_mm
    @height_mm    = height_mm
    @border_x_mm  = border_x_mm
    @border_y_mm  = border_y_mm.nil? ? border_x_mm : border_y_mm
    @spacing_y_mm = spacing_y_mm.nil? ? @border_y_mm : spacing_y_mm
    @y_tracker_mm = @border_y_mm
    @strips = []

    @img = Rasem::SVGImage.new( "%dmm" % @width_mm, "%dmm" % @height_mm )
  end

  # TODO throw exception when tracker would reach beyond the bottom border
  def create_strip ( height_mm, scale_height_mm, width_mm = nil )
    strip = Strip.new( self,
                       width_mm.nil? ? @width_mm - 2 * @border_x_mm : width_mm,
                       height_mm,
                       @border_x_mm,
                       @y_tracker_mm,
                       scale_height_mm )
    @strips << strip
    @y_tracker_mm += height_mm + @spacing_y_mm
    return strip
  end

  def render ( )
    @strips.each do | strip |
      strip.render( )
    end
    @img.close
    return @img.output
  end
end

sheet = Sheet.new( )
strip = sheet.create_strip( 15, 3.2 )
scale = strip.create_scale( 2 )
scale.add_constants( )
strip = sheet.create_strip( 25, 3.2 )
scale = strip.create_scale( 2, 30 )
scale = strip.create_scale( 3, 30, 7 )
scale = strip.create_scale( 1, 30, 21, true )
scale.add_constants( )
strip = sheet.create_strip( 15, 3.2 )
scale = strip.create_scale( 1 )
scale.add_constants( )
#dec = DecimalScale.new( 300, 5, 2 )
#dec.add_constants()
puts sheet.render( )

