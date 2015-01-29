#!/usr/bin/ruby

# vim: et

require_relative 'backprint'
require_relative 'table'

module Io::Creat::Slipstick
  module Backprints

    class ConstantsBackprint < Backprint
      CONSTANTS =  [ [ 'imaginary',             'i²', "-1" ],
                     [ 'Meissel–Mertens',       'M₁', "\u00a00.2614972128" ],
                     [ 'Omega',                  'Ω', "\u00a00.5671432904" ],
                     [ 'Euler-Mascheroni',       'γ', "\u00a00.5772156649" ],
                     [ 'Apéry',                  'ζ', "\u00a01.2020569032" ],
                     [ 'Pythagoras',       "\u221b2", "\u00a01.4142135624" ],
                     [ 'Ramanujan-Soldner',      'μ', "\u00a01.4513692349" ],
                     [ 'Golden ratio',           'φ', "\u00a01.6180339887" ],
                     [ 'Theodorus',        "\u221b3", "\u00a01.7320508076" ],
                     [ '',                 "\u221b5", "\u00a02.2360679775" ],
                     [ 'Euler',                  'e', "\u00a02.7182818285" ],
                     [ 'Archimedes',             'π', "\u00a03.1415926536" ],
                     [ 'Reciprocal Fibonacci',   'ψ', "\u00a03.3598856662" ],
                   ]
      PHYS = [ [ 'Astronomic unit' ],
               [ 'Speed of light' ] ]
      def render ( )
        my_mm = @y_mm - @h_mm / 2
        w_mm = @fs_mm * 2.5
        h_mm = @h_mm / 12
        fs_mm = h_mm / 1.6
        style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::LOTICK].merge( { Io::Creat::Slipstick::Key::FONT_SIZE => fs_mm } )
        spacing = @fs_mm * 0.2
        tables = []
        table = Table.new( @img, @x_mm, @y_mm, spacing, style )
        CONSTANTS.each do | constant |
          tr = table.tr( h_mm )
            td = tr.td( constant[0], 4.5 * w_mm )
            td = tr.td( constant[1], 1 * w_mm, Td::MID )
            td = tr.td( constant[2], 3 * w_mm )
        end
        tables << table
        tables.each do | table |
          table.render()
        end
      end

      public
      def getw ( )
        return 8.5 * @fs_mm * 2.5
      end

    end # ConstantsBackprint

    public
    def getw()
      return 10 * @fs_mm * 2.5
    end

  end # Backprints
end # Io::Creat::Slipstick


