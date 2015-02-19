
# vim: et

require_relative 'backprint'
require_relative 'table'

module Io::Creat::Slipstick::Backprints

  # table depicting which scales are for which calculations
  class InstructionsBackprint < Backprint

    DATA = [ [ 'multiply, divide',    'A + B, C + D' ],
             [ 'reciprocal division', 'C + CI' ],
             [ 'power, radix',        'D + LL1, D + LL2, D + LL3' ],
             [ 'cube root',           'D + K' ],
             [ 'logarithm',           'D + L' ],
             [ 'sine',                'S, ST' ],
             [ 'tangent',             'T, ST' ],
             [ 'cosine',              'S + P' ]
           ]
    public
    def setw ( w_mm ) @w_mm = w_mm end

    public
    def render ( )
      spacing = @fs_mm * 0.2
      h_mm = @w_mm / DATA.length
      fs_mm = h_mm / 1.8
      style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::SCALE].merge( { Io::Creat::Slipstick::Key::FONT_SIZE => fs_mm } )
      table = Table.new( @img, @x_mm, @y_mm, spacing, Table::ORIENT_PORTRAIT, style )
      DATA.each do | cols |
        tr = table.tr( h_mm )
          td = tr.td( cols[0], 0.43 * @h_mm )
          td = tr.td( cols[1], 0.57 * @h_mm, Td::MID )
      end
      table.render()
    end

  end # InstructionsBackprint

end # Io::Creat::Slipstick::Backprints