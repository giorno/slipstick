
# vim: et

require_relative 'backprint'
require_relative 'table'

module Io::Creat::Slipstick
  module Backprints

    class ConstantsBackprint < Backprint
      MATH = [ [ 'imaginary',             'i²', "-1" ],
               [ 'Meissel–Mertens',       'M₁', "\u00a00.26149721284764278376" ],
               [ 'Omega',                  'Ω', "\u00a00.567143290409783872" ],
               [ 'Euler-Mascheroni',       'γ', "\u00a00.57721566490153286061" ],
               [ 'Apéry',                  'ζ', "\u00a01.2020569031595942854" ],
               [ 'Pythagoras',       "\u221b2", "\u00a01.41421356237309504i88" ],
               [ 'Ramanujan-Soldner',      'μ', "\u00a01.45136923488338105028" ],
               [ 'Golden ratio',           'φ', "\u00a01.61803398874989484820" ],
               [ 'Theodorus',        "\u221b3", "\u00a01.73205080756887729353" ],
               [ '',                 "\u221b5", "\u00a02.23606797749978969641" ],
               [ 'Euler',                  'e', "\u00a02.71828182845904523536" ],
               [ 'Archimedes',             'π', "\u00a03.14159265358979323846" ],
               [ 'recipr. Fibonacci',      'ψ', "\u00a03.35988566624317755317" ],
             ]
      PHYS = [ [ 'astronomical unit',     'au', '1.4960×10¹¹ m' ],
               [ 'speed of light',         'c', '2.9979×10¹⁰ m·s⁻¹' ],
               [ 'gravitational',          'G', '6.6738×10⁻¹¹ m³·kg⁻¹·s⁻²' ],
               [ 'Planck',                 'ℎ', '6.6261×10⁻³⁴ J·s' ],
               [ 'reduced Planck',         'ℏ', '1.0546×10⁻³⁴ J·s' ],
               [ 'permeability (vac.)',   'µ₀', '1.2566×10⁻⁶ N·A⁻²' ],
               [ 'permitivity (vac.)',    'ε₀', '8.8542×10⁻¹² F·m⁻¹' ],
               [ 'impedance (vac.)',      'Z₀', '3.7673×10² Ω' ],
               [ 'Coulomb',          "k\u2091", '8.9876×10⁹ N·m²·C⁻²' ],
               [ 'elementary charge',      'e', '1.6022×10⁻¹⁹ C' ],
               [ 'Bohr magneton',    "µ\u1d03", '9.2740×10⁻²⁴ J·T⁻¹' ], # Slipstick Sans Mono glyph for this code point is subscript capital letter B
               [ 'Boltzmann',              'k', '1.3806×10⁻²³ J·K⁻¹' ],
               [ 'molar gas',              'R', '8.3145 J·K⁻¹·mol⁻¹' ],
               [ 'Avogadro',         "N\u1d00", '6.0221x10²³ mol⁻¹' ],
               [ 'Faraday',                'F', '9.6485×10⁴ C·mol⁻¹' ],
               [ 'electron mass',    "m\u2091", '9.1094×10⁻³¹ kg' ],
               [ 'proton mass',      "m\u209a", '1.6726×10⁻²⁷ kg' ],
               [ 'neutron mass',     "m\u2099", '1.6749×10⁻²⁷ kg' ],
               [ 'atomic mass',            'u', '1.6605×10⁻²⁷ kg' ],
               [ 'Stefan-Boltzmann',       'σ', '5.6704×10⁻⁸ W·m⁻²·K⁻⁴' ],
               [ 'Rydberg',          "R\u1d02", '1.09737×10⁷ m⁻¹' ],
               [ 'flux quantum',           'Φ', '2.0678×10⁻¹⁵ Wb' ],
               [ 'atmosphere',           'atm', '101325 Pa' ],
               [ 'Wien displacement',      'b', '2.8978×10⁻³ m·K' ],
               [ 'Bohr radius',           'a₀', '5.2918×10⁻¹¹ m' ],
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


