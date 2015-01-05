
# also initializes basic namespaces
module Io
  module Creat
    module Slipstick

      module Key
        LINE_WIDTH    = 1
        LINE_COLOR    = 2
        FONT_FAMILY   = 10
        FONT_WEIGHT   = 11
        FONT_STYLE    = 12
        FONT_COLOR    = 13
        FONT_SIZE     = 14
        FONT_SPACING  = 15 # SVG letter-spacing property
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
        TICK     = 10 # regular tick for a calculated value
        LOTICK   = 20 # small font tick for a calculated value
        SCALE    = 30 # single scale
        CONSTANT = 40 # tick for a pre-defined constant
      end

      module Style
        # style is associated with entity (per entity)
        ENTITY = { Io::Creat::Slipstick::Key::LINE_WIDTH   => 0.11, # mm
                   Io::Creat::Slipstick::Key::LINE_COLOR   => 'black',
                   Io::Creat::Slipstick::Key::FONT_FAMILY  => 'Droid Sans Mono,Arial,Sans-serif',
                   Io::Creat::Slipstick::Key::FONT_WEIGHT  => 'normal',
                   Io::Creat::Slipstick::Key::FONT_STYLE   => 'normal',
                   Io::Creat::Slipstick::Key::FONT_COLOR   => 'black',
                   Io::Creat::Slipstick::Key::FONT_SPACING => -0.15,
                   Io::Creat::Slipstick::Key::FONT_SIZE    => 3.0, # mm
                 }
        # per scale style
        DEFAULT = { Io::Creat::Slipstick::Entity::TICK     => ENTITY,
                    Io::Creat::Slipstick::Entity::LOTICK   => ENTITY.merge( { Io::Creat::Slipstick::Key::FONT_SIZE => 2.4 } ),
                    Io::Creat::Slipstick::Entity::SCALE    => ENTITY.merge( { Io::Creat::Slipstick::Key::FONT_SIZE => 2.4 } ),
                    Io::Creat::Slipstick::Entity::CONSTANT => ENTITY.merge( { Io::Creat::Slipstick::Key::FONT_FAMILY => 'Droid Serif,Arial,Sans-serif', Io::Creat::Slipstick::Key::FONT_WEIGHT => 'normal', Io::Creat::Slipstick::Key::FONT_STYLE => 'italic', Io::Creat::Slipstick::Key::FONT_SIZE => 2.4 } )
                  }

        SMALL = DEFAULT.merge( Io::Creat::Slipstick::Entity::TICK => DEFAULT[Io::Creat::Slipstick::Entity::LOTICK].merge( { Io::Creat::Slipstick::Key::FONT_SIZE => 2.4 } ) )
      end

      # dimensions controlling rendering of a scale (per scale)
      module Dim
        DEFAULT = { Io::Creat::Slipstick::Key::TICK_HEIGHT   => [ 1.0, 0.9, 0.78, 0.66, 0.54, 0.42, 0.3 ],
                    Io::Creat::Slipstick::Key::TICK_OVERFLOW => 0, # mm
                    Io::Creat::Slipstick::Key::CLEARING      => 0.4, # mm, min distance between neighbouring ticks
                    # number of smallest ticks to fill ranges:  ticks => groupings (for tick height calculation)
                    Io::Creat::Slipstick::Key::FODDERS       => { #100 => [ 5, 10, 50 ],
                                                                   50 => [ 5, 10 ],
                                                                   25 => [ 5 ],
                                                                   10 => [ 5 ],
                                                                    5  => [ ],
                                                                    2  => [ ] },
                    Io::Creat::Slipstick::Key::VERT_CORR     => [ -0.05, 0.85 ], # corrections to workaround lack of support for dominant-baseline
                  }
      end

      module Flag
        RENDER_SUBSCALE   = 1
        RENDER_AFTERSCALE = 2
      end
    end
  end
end

