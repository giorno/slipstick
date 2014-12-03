#!/usr/bin/ruby

require_relative 'sheet'

sheet = Io::Creat::Slipstick::Layout::Sheet.new( )
strip = sheet.create_strip( 5.0, 250.0, 5.0, 20.0, 15.0 )
scale = strip.create_scale( "x²", 2, 0, true )
scale.add_constants( )
strip = sheet.create_strip( 15.0, 250.0, 5.0, 20.0, 15.0 )
scale = strip.create_scale( "x²", 2, 0, false )
scale = strip.create_scale( "x³", 3, 6.0, true )
scale = strip.create_scale( "x", 1, 14.0, true )
scale.add_constants( )
strip = sheet.create_strip( 5.0, 250.0, 5.0, 20.0, 15.0 )
scale = strip.create_scale( "x", 1, 30.0 )
scale.add_constants( )

puts sheet.render( )

