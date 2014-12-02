#!/usr/bin/ruby

require './layout'

sheet = Io::Creat::Slipstick::Layout::Sheet.new( )
strip = sheet.create_strip( 15, 200 )
scale = strip.create_scale( "x²", 2, 0, true )
#scale.add_subscale( 20 )
#scale.add_constants( )
strip = sheet.create_strip( 15, 287 )
scale = strip.create_scale( "x²", 2, 0, false )
#scale.add_subscale( 20 )
scale = strip.create_scale( "x³", 3, 6, true )
#scale.add_subscale( 20 )
scale = strip.create_scale( "x", 1, 14, true )
#scale.add_subscale( 20 )
#scale.add_constants( )
strip = sheet.create_strip( 15, 200 )
scale = strip.create_scale( "x", 1, 30 )
#scale.add_subscale( 20 )
#scale.add_constants( )

puts sheet.render( )

