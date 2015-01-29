#!/usr/bin/ruby

# vim: et

require_relative 'backprint'
require_relative 'table'

module Io::Creat::Slipstick
  module Backprints

    class ConstantsBackprint < Backprint
      CONSTANTS =  [ [ 'imaginary',       'i²', '-1' ],
                     [ 'Meissel–Mertens', 'M₁', '0.26149 72128' ],
                     [ 'Omega',           'Ω',  '0.56714 32904' ],
                     [ 'Euler-Mascheroni', 'γ', '0.57721 56649' ],
                     [ 'Apéry',            'ζ', '1.20205 69032' ],
                     [ 'Pythagoras',       "\u221b2", '1.41421 35624' ],
                     [ 'Ramanujan-Soldner', 'μ', '1.45136 92349' ],
                     [ 'Golden ration', 'φ', '1.61803 39887' ],
                     [ 'Theodorus', "\u221b3", '1.73205 08076' ],
                     [ '', "\u221b5", '2.23606 79775' ],
                     [ 'Euler', 'e', '2.71828 18285' ],
                     [ 'Archimedes', 'π', '3.14159 26536' ],
                     [ 'Reciprocal Fibonacci', 'ψ', '3.35988 56662' ],
                   ]
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
            td = tr.td( constant[0], 5 * w_mm )
            td = tr.td( constant[1], 1 * w_mm, Td::MID )
            td = tr.td( constant[2], 4 * w_mm )
        end
        tables << table
        tables.each do | table |
          table.render()
        end
      end

    end # ConstantsBackprint

    public
    def getw()
      return 10 * @fs_mm * 2.5
    end

  end # Backprints
end # Io::Creat::Slipstick


