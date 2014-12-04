#!/usr/bin/ruby

require_relative 'sheet'

sheet = Io::Creat::Slipstick::Layout::Sheet.new( )
strip = sheet.create_strip( 15.0, 250.0, 5.0, 20.0, 15.0 )
scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "", 25, 0 )
scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "log x", 10, 0 )
scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 2, 0, true )
scale.add_constants( )
strip = sheet.create_strip( 15.0, 250.0, 5.0, 20.0, 15.0 )
scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 2, 0, false )
scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x³", 3, 6.0, true )
scale.set_flags( 0 )
scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 1, 14.0, true )
scale.add_constants( )
strip = sheet.create_strip( 10.0, 250.0, 5.0, 20.0, 15.0 )
scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 1, 30.0 )
scale.add_constants( )
scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "1/x", 2, 30.0, false, true )
scale.add_constants( )
scale.set_flags( 0 )

puts sheet.render( )

