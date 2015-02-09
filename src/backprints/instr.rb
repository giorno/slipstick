
# vim: et

require_relative 'backprint'
require_relative 'table'

module Io::Creat::Slipstick::Backprints

  # table depicting which scales are for which calculations
  class InstructionsBackprint < Backprint

    public
    def render ( )
      spacing = @fs_mm * 0.2
      table = Table.new( @img, @x_mm, @y_mm, spacing, Table::ORIENT_LANDSCAPE, style )
      #  tr = table.tr( 
      table.render()
    end

  end # InstructionsBackprint

end # Io::Creat::Slipstick::Backprints
