#!/usr/bin/ruby

# vim: et

require_relative 'backprint'
require_relative 'table'

module Io::Creat::Slipstick
  module Backprints

    class ConstantsBackprint < Backprint
      MATH = [ [ 'imaginary',             'i²', "-1" ],
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
               [ 'reciprocal Fibonacci',   'ψ', "\u00a03.3598856662" ],
             ]
      PHYS = [ [ 'astronomical unit',      'au', '1.4960×10¹¹ m' ],
               [ 'speed of light',         'c', '2.9979×10¹⁰ m·s⁻¹' ],
               [ 'gravitational',          'G', '6.6738×10⁻¹¹ m³·kg⁻¹·s⁻²' ],
               [ 'Planck',                 'ℎ', '6.6261×10⁻³⁴ J·s' ],
               [ 'reduced Planck',         'ℏ', '1.0546×10⁻³⁴ J·s' ],
               [ 'permeability (vac.)', 'µ0', '1.2566×10−6 N·A⁻²' ],
               [ 'permitivity (vac.)',  'ε0', '8.8542×10⁻¹² F·m⁻¹' ],
               [ 'impedance (vac.)',    'Z0', '3.7673×10² Ω' ],
               [ 'Coulomb',               'ke', '8.9876×10+9 N·m²·C⁻²' ],
               [ 'elementary charge',     'e',  '1.6022×10⁻¹9 C' ],
               [ 'Bohr magneton',         'µB', '9.2740×10−24 J·T⁻¹' ],
               [ 'Boltzmann',             'k', '1.3806×10−23 J·K⁻¹' ],
               [ 'molar gas',             'R', '8.3145 J·K⁻¹·mol⁻¹' ],
               [ 'Avogadro',             'NA', '6.0221 x 1023 mol⁻¹' ],
               [ 'Faraday',      'F', '9.6485×104 C·mol⁻¹' ],
               [ 'electron mass',      'me', '9.1094×10−31 kg' ],
               [ 'proton mass',             'mp', '1.6726×10−27 kg' ],
               [ 'neutron mass',             'mn', '1.6749×10−27 kg' ],
               [ 'atomic mass',             'u', '1.6605×10−27 kg' ],
               [ 'Stefan-Boltzmann',       'σ', '5.6704×10−8 W·m−2·K−4' ],
               [ 'Rydberg',             'Roo', '1.09737×107 m⁻¹' ],
               [ 'flux quantum',             'Φ', '2.0678×10⁻¹5 Wb' ],
               [ 'atmosphere',             'atm', '101325 Pa' ],
               [ 'Wien displacement',             'b', '2.8978×10−3 m·K' ],
               [ 'Bohr radius',             'a0', '5.2918×10⁻¹¹ m' ],
             ]

      def render ( )
        my_mm = @y_mm - @h_mm / 2
        w_mm = @fs_mm * 2.5
        h_mm = @h_mm / 14
        fs_mm = h_mm / 1.8
        w1_mm = 0.40 * @h_mm
        w2_mm = 0.10 * @h_mm
        w3_mm = 0.50 * @h_mm
        style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::SCALE].merge( { Io::Creat::Slipstick::Key::FONT_SIZE => fs_mm } )
        spacing = @fs_mm * 0.2
        tables = []
        table = Table.new( @img, @x_mm, @y_mm, spacing, Table::ORIENT_LANDSCAPE, style )
          tr = table.tr( h_mm )
            td = tr.td( 'MATHEMATICAL CONSTANTS', @h_mm, Td::MID )
        MATH.each do | constant |
          tr = table.tr( h_mm )
            td = tr.td( constant[0], w1_mm )
            td = tr.td( constant[1], w2_mm, Td::MID )
            td = tr.td( constant[2], w3_mm )
        end
        #tables << table
        #w1_mm = 0.50 * @h_mm
        #w2_mm = 0.10 * @h_mm
        #w3_mm = 0.60 * @h_mm
        #table = Table.new( @img, @x_mm + @h_mm + h_mm, @y_mm, spacing, Table::ORIENT_PORTRAIT, style )
          tr = table.tr( h_mm )
            td = tr.td( 'PHYSICAL CONSTANTS', w1_mm + w2_mm + w3_mm, Td::MID )
        PHYS.each do | constant |
          tr = table.tr( h_mm )
            td = tr.td( constant[0], w1_mm )
            td = tr.td( constant[1], w2_mm, Td::MID )
            td = tr.td( constant[2], w3_mm )
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


