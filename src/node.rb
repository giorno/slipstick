
require_relative 'constants'

module Io::Creat::Slipstick

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
	@style    = Io::Creat::Slipstick::STYLE
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

    # todo accessor
    public
    def set_style ( style )
      @style = style
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

end

