
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
        DEFAULT = { Io::Creat::Slipstick::Key::TICK_HEIGHT   => [ 1.0, 0.85, 0.7, 0.55, 0.4, 0.25 ],
                    Io::Creat::Slipstick::Key::TICK_OVERFLOW => 0, # mm
                    Io::Creat::Slipstick::Key::CLEARING      => 0.4, # mm, min distance between neighbouring ticks
                    Io::Creat::Slipstick::Key::FODDERS       => [ 100.0, 50.0, 25.0, 10.0, 5.0, 2.0 ], # number of smallest ticks to fill range between majors and their halfs
                    Io::Creat::Slipstick::Key::VERT_CORR     => [ -0.2, 0.9 ], # corrections to workaround lack of support for dominant-baseline
                  }
      end

      module Flag
        RENDER_SUBSCALE   = 1
        RENDER_AFTERSCALE = 2
      end
    end
  end
end

