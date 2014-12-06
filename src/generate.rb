#!/usr/bin/ruby

require_relative 'sheet'

sheet = Io::Creat::Slipstick::Layout::Sheet.new( )

  strip = sheet.create_strip( 15.0, 250.0, 5.0, 20.0, 15.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "", 0 )
      scale.set_params( 25 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "log x", 0 )
      scale.set_params( 10 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0, true )
      scale.set_params( 2 )
      scale.add_constants( )

  strip = sheet.create_strip( 15.0, 250.0, 5.0, 20.0, 15.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0 )
      scale.set_params( 2 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x³", 6.0, true )
      scale.set_params( 3 )
      scale.set_flags( 0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 14.0, true )
      scale.set_params( 1 )
      scale.add_constants( )

  strip = sheet.create_strip( 25.0, 250.0, 5.0, 20.0, 15.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 30.0 )
      scale.set_params( 1 )
      scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "1/x", 30.0 )
      scale.set_params( 1, true )
      scale.add_constants( )
      scale.set_flags( 0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SIN, "sin", 30.0 )
      scale.set_params( 90, 5, [ 1, 5, 10, 20 ] )
      scale.set_flags( 0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_TAN, "tan", 30.0 )
      scale.set_params( 45, 5, [ 1, 5, 10, 20 ] )
      scale.set_flags( 0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SINTAN, "s-t", 30.0 )
      scale.set_params( 6, 0.5, [ 1.0 / 12.0, 0.5 ], 8 )
      scale.set_flags( 0 )

puts sheet.render( )

