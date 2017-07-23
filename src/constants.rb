
# vim: et

# also initializes basic namespaces
module Io
  module Creat
    module Slipstick

      module Key
        TICK_HEIGHT   = 210 # relative height of a tick, depending on the range subdivision
        TICK_OVERFLOW = 220 # how far beyond the scale border the tick shall overlap
        TICK_CLEARING = 230 # minimal distance between neighbouring ticks
        CLEARING      = 240
        FODDERS       = 250
        VERT_CORR     = 260
      end

      # pre-defined constants
      CONST_MATH = { "e" => Math::E, "π" => Math::PI, "√2" => Math.sqrt( 2 ), "φ" => 1.61803398874 }

      module Entity
        TICK     = 0x10 # regular tick for a calculated value
        HITICK   = 0x20 # regular tick with bold font (supermajor indexes)
        LOTICK   = 0x30 # small font tick for a calculated value
        LABEL    = 0x40 # scale label
        SCALE    = 0x50 # single scale (deprecated as it is abused in so many places)
        UNITS    = 0x60 # units conversion scales
        CONSTANT = 0x70 # tick for a pre-defined constant
        BRANDING = 0x80 # branding tags (rounded rectangle, white text on color)
        PAGENO   = 0x90 # page numbers
        AUX      = 0xa0 # auxilliary lines (content not present in the product, such as cutting lines, comments)
        QR       = 0xb0 # QR code style
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
                                                                   20 => [ 4 ],
                                                                   10 => [ 5 ],
                                                                   10.0 => [ 2 ],
                                                                    5  => [ ],
                                                                    2  => [ ] },
                    Io::Creat::Slipstick::Key::VERT_CORR     => [ -0.15, 0.85 ], # corrections to workaround lack of support for dominant-baseline
                  }
      end

      
      module Flag
        RENDER_SUBSCALE   = 1
        RENDER_AFTERSCALE = 2
      end
    end
  end
end

