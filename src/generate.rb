#!/usr/bin/ruby

require './layout'

sheet = Io::Creat::Slipstick::Layout::Sheet.new( )
strip = sheet.create_strip( 15, 3.2 )
scale = strip.create_scale( "x²", 2, 30, 10, true )
scale.add_subscale( 20 )
scale.add_constants( )
strip = sheet.create_strip( 25, 3.2 )
scale = strip.create_scale( "x²", 2, 30 )
scale.add_subscale( 20 )
scale = strip.create_scale( "x³", 3, 30, 7 )
scale.add_subscale( 20 )
scale = strip.create_scale( "x", 1, 30, 21, true )
scale.add_subscale( 20 )
scale.add_constants( )
strip = sheet.create_strip( 15, 3.2 )
scale = strip.create_scale( "x", 1, 30 )
scale.add_subscale( 20 )
scale.add_constants( )

puts sheet.render( )

