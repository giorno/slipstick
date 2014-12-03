
require './hierarchy'

module Io::Creat::Slipstick

  module Key
    LINE_WIDTH    = 1
    LINE_COLOR    = 2
    FONT_FAMILY   = 10
    FONT_WEIGHT   = 11
    FONT_STYLE    = 12
    FONT_COLOR    = 13
    FONT_SIZE     = 14
    TICK_HEIGHT   = 21 # relative height of a tick, depending on the range subdivision
    TICK_OVERFLOW = 22 # how far beyond the scale border the tick shall overlap
    TICK_CLEARING = 23 # minimal distance between neighbouring ticks
    CLEARING      = 24
    FODDERS       = 25
    VERT_CORR     = 26
  end

  # pre-defined constants
  CONST_MATH = { "e" => Math::E, "π" => Math::PI, "√2" => Math.sqrt( 2 ), "φ" => 1.61803398874 }

  module Entity
    TICK     = 1 # regular tick for a calculated value
    SCALE    = 2 # single scale
    CONSTANT = 3 # tick for a pre-defined constant
  end

  module Style
    # style is associated with entity (per entity)
    ENTITY = { Io::Creat::Slipstick::Key::LINE_WIDTH  => 0.1, # mm
               Io::Creat::Slipstick::Key::LINE_COLOR  => 'black',
               Io::Creat::Slipstick::Key::FONT_FAMILY => 'Arial',
               Io::Creat::Slipstick::Key::FONT_WEIGHT => 'bold',
               Io::Creat::Slipstick::Key::FONT_STYLE  => 'normal',
               Io::Creat::Slipstick::Key::FONT_COLOR  => 'black',
               Io::Creat::Slipstick::Key::FONT_SIZE   => 2.1, # mm
             }
    # per scale style
    DEFAULT = { Io::Creat::Slipstick::Entity::TICK     => ENTITY,
                Io::Creat::Slipstick::Entity::SCALE    => ENTITY,
                Io::Creat::Slipstick::Entity::CONSTANT => ENTITY.merge( { Io::Creat::Slipstick::Key::FONT_WEIGHT => 'normal', Io::Creat::Slipstick::Key::FONT_STYLE => 'italic' } )
              }
  end

  # dimensions controlling rendering of a scale (per scale)
  module Dim
    DEFAULT = { Io::Creat::Slipstick::Key::TICK_HEIGHT   => [ 1.0, 0.8, 0.7, 0.6, 0.45, 0.4 ],
                Io::Creat::Slipstick::Key::TICK_OVERFLOW => 0, # mm
                Io::Creat::Slipstick::Key::CLEARING      => 0.38, # mm, min distance between neighbouring ticks
                Io::Creat::Slipstick::Key::FODDERS       => [ 50.0, 25.0, 10.0, 5.0, 2.0 ], # number of smallest ticks to fill range between majors and their halfs
                Io::Creat::Slipstick::Key::VERT_CORR     => [ -0.2, 0.9 ], # corrections to workaround lack of support for dominant-baseline
              }
  end

  class Node
    public
    def initialize ( parent, rel_off_x_mm, rel_off_y_mm )
      @parent = parent
      # root node
      if @parent.nil?
        @img      = nil # creation deferred to the tree root node
	# defaults
        @off_x_mm = rel_off_x_mm
	@off_y_mm = rel_off_y_mm
	@style    = Io::Creat::Slipstick::Style::DEFAULT
	@dim      = Io::Creat::Slipstick::Dim::DEFAULT
      else
        # tree node or leaf -> derive/inherit from the parent
        @img      = @parent.instance_variable_get( :@img )
	assert( )
        @off_x_mm = @parent.instance_variable_get( :@off_x_mm ) + rel_off_x_mm
        @off_y_mm = @parent.instance_variable_get( :@off_y_mm ) + rel_off_y_mm
	@style    = @parent.instance_variable_get( :@style )
	@dim      = @parent.instance_variable_get( :@dim )
        @parent.instance_variable_get( :@children ) << self # wire up
      end
      @children = []
    end

    # make sure that @img instance is initialized
    private
    def assert ( )
	raise "SVG image not initialized in parent (likely the tree root node did not initialize it)!" unless not @img.nil?
    end

    # call render on children
    public
    def render ( )
        assert( )
	@children.each do | child |
	  child.render( )
	end
    end
  end

  class Scale < Node
    public
    def initialize ( parent, label, rel_off_x_mm, rel_off_y_mm, h_mm, flipped = false )
      super( parent, rel_off_x_mm, rel_off_y_mm )
      @label          = label
      @h_mm           = h_mm
      # copy widths from the parent
      @w_mainscale_mm = @parent.instance_variable_get( :@w_mainscale_mm )
      @w_label_mm     = @parent.instance_variable_get( :@w_label_mm )
      @w_subscale_mm  = @parent.instance_variable_get( :@w_subscale_mm )
      @w_after_mm     = @parent.instance_variable_get( :@w_after_mm )
      @flipped        = flipped
    end

    def calc_tick_font_height_mm ( )
      return @style[Io::Creat::Slipstick::Entity::TICK][Io::Creat::Slipstick::Key::FONT_SIZE] * 1.3
    end

    def render_label ( )
      if not @label.nil? and @w_label_mm > 0
        font_size_mm = @style[Io::Creat::Slipstick::Entity::SCALE][Io::Creat::Slipstick::Key::FONT_SIZE]
        @img.text( "%fmm" % ( @off_x_mm + @w_label_mm / 2),
                   "%fmm" % ( @off_y_mm + ( @flipped ? @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] : @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] ) * font_size_mm ),
                   "%s" % @label,
                   { "fill" => @style[Io::Creat::Slipstick::Entity::SCALE][Io::Creat::Slipstick::Key::FONT_COLOR],
                     "font-size" => "%fmm" % font_size_mm,
                     "font-family" => @style[Io::Creat::Slipstick::Entity::SCALE][Io::Creat::Slipstick::Key::FONT_FAMILY],
                     "text-anchor" => "middle",
                     "font-weight" => @style[Io::Creat::Slipstick::Entity::SCALE][Io::Creat::Slipstick::Key::FONT_WEIGHT] } )
      end
    end

    # draws a vertical line with the current line style and optionally adds
    # a label to it
    protected
    def render_tick ( x_mm, h_mm, label = nil, style = Io::Creat::Slipstick::Entity::TICK )
      flip = @flipped ? -1 : 1
      @img.line( "%fmm" % ( @off_x_mm + x_mm ),
                 "%fmm" % ( @off_y_mm - flip * ( style == Io::Creat::Slipstick::Entity::CONSTANT ? -@dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][2] * h_mm : @dim[Io::Creat::Slipstick::Key::CLEARING] ) ),
                 "%fmm" % ( @off_x_mm + x_mm ),
                 "%fmm" % ( @off_y_mm + flip * h_mm ),
                 { "stroke" => @style[style][Io::Creat::Slipstick::Key::LINE_COLOR],
                   "stroke-width" => "%fmm" % @style[style][Io::Creat::Slipstick::Key::LINE_WIDTH],
                   "stroke-linecap" => "square" } )
      if not label.nil?
        font_size_mm = @style[style][Io::Creat::Slipstick::Key::FONT_SIZE]
        @img.text( "%fmm" % ( @off_x_mm + x_mm ),
                   "%fmm" % ( flip * h_mm + @off_y_mm + ( @flipped ? @dim[Io::Creat::Slipstick::Key::VERT_CORR][0] : @dim[Io::Creat::Slipstick::Key::VERT_CORR][1] ) * font_size_mm ), # compensation for ignored (by viewers) vertical alignments
                   "%s" % label,
                   { "fill" => @style[style][Io::Creat::Slipstick::Key::FONT_COLOR],
                     "font-size" => "%fmm" % font_size_mm,
                     "font-family" => @style[style][Io::Creat::Slipstick::Key::FONT_FAMILY],
                     "font-style" => @style[style][Io::Creat::Slipstick::Key::FONT_STYLE],
                     "text-anchor" => "middle",
                     "dominant-baseline" => "hanging", # seems to be ignored by viewers
                     "font-weight" => @style[style][Io::Creat::Slipstick::Key::FONT_WEIGHT] } )
      end
    end
  end

  # a leaf node
  class DecimalScale < Scale

    public
    def initialize ( parent, label, size, rel_off_x_mm, rel_off_y_mm, h_mm, flipped = false )
      super( parent, label, rel_off_x_mm, rel_off_y_mm, h_mm, flipped )

      @size          = size
      @constants     = {}
    end

    # these constants will be added as explicit ticks with cursive names when render() is called
    # predefined: Euler's number, Pythagoras' number, square root of 2, Fibonacci's number
    public
    def add_constants ( constants = CONST_MATH  )
      @constants = constants
    end

    public
    def add_subscale ( left_border_mm ) # disabled
      @left_border_mm = left_border_mm
    end

    public
    def render ( )
      last = @w_label_mm + @w_subscale_mm
      for i in 1..@size
        # next tick
        upper = 10 ** i
        step = upper / 20.0
        base = 10 ** ( i - 1 ) 
        for j in 0..18
          value = base + j * step
          # physical dimension coordinates
          x = @w_label_mm + @w_subscale_mm + Math.log10( value ) * @w_mainscale_mm / @size
          h = @h_mm * ( j == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][0] : ( j % 2 == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][2] ) )
          if j < 18 # last one is not rendered, but is required for small ticks calculation
           render_tick( x, h, ( j % 2 ) == 0 ? "%d" % value : nil )
          end

          if j > 0
            # fill the range with smallest ticks
            delta = x - last
            no_smallest = 0
            @dim[Io::Creat::Slipstick::Key::FODDERS].each do | no |
              if delta > no * @dim[Io::Creat::Slipstick::Key::CLEARING]
                no_smallest = no
                break
              end
            end

            if no_smallest > 0
              stepper = step / no_smallest
              for k in 1..no_smallest - 1
                mx = @w_label_mm + @w_subscale_mm + Math.log10( base + ( j  - 1 ) * step + k * stepper ) * @w_mainscale_mm / @size
                h = @h_mm * ( k % ( no_smallest / 5 )  == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][3] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][4] )
                render_tick( mx, h, nil )
              end
            end
          end
          last = x
        end
      end
      # last tick
      render_tick( @w_label_mm + @w_subscale_mm + @w_mainscale_mm, @h_mm, "%d" % ( 10 ** @size ) )
      # label
      render_label( )
      # add constants if any specified
      render_constants()
      render_subscale()
    end


    private
    def render_constants() # disabled
      @constants.each do | name, value |
        x = @w_label_mm + @w_subscale_mm + Math.log10( value ) * @w_mainscale_mm / @size
        h = @h_mm * @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1]
        render_tick( x, h, "%s" % name, Io::Creat::Slipstick::Entity::CONSTANT )
      end
    end

    # fill range given by border with short scale of log() for values under 1 to the left of the 1 tick
    private
    def render_subscale ( )
      if @w_subscale_mm <= 0
        return
      end

      value = 1
      last = @w_label_mm + @w_subscale_mm
      step = 0.02
      while true do
        value -= step
        x = @w_label_mm + @w_subscale_mm + Math.log10( value ) * @w_mainscale_mm / @size
        if x <= @w_label_mm
          return
        end
        round = ( value * 20 ).round( 2 ) % 2 == 0
        h = @h_mm * ( round ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][1] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][2] )
        render_tick( x, h, ( round ? ( "%.1f" % value )[1..-1] : nil ) )

        # filler
        delta = last - x
        no_smallest = 0
        @dim[Io::Creat::Slipstick::Key::FODDERS].each do | no |
         if delta >= no * @dim[Io::Creat::Slipstick::Key::CLEARING]
            no_smallest = no
            break
         end
        end
        if no_smallest > 0
          stepper = step / no_smallest
          for k in 1..no_smallest - 1
            mx = @w_label_mm + @w_subscale_mm + Math.log10( value + k * stepper ) * @w_mainscale_mm / @size
            h = @h_mm * ( k % ( no_smallest / 5 )  == 0 ? @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][3] : @dim[Io::Creat::Slipstick::Key::TICK_HEIGHT][4] )
            render_tick( mx, h, nil )
          end
        end
        last = x
      end
    end

  end
end

