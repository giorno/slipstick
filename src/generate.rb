#!/usr/bin/ruby

require_relative 'sheet'

sheet = Io::Creat::Slipstick::Layout::Sheet.new( )

  sheet.create_label( "LOGAREX 27403-II: L P K A | B CI C | D S T ST" )
  # LOGAREX 27403-II
  strip = sheet.create_strip( 30.0, 250.0, 10.0, 15.0, 15.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "", 0 )
      scale.set_params( 25 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "log x", 0 )
      scale.set_params( 10 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_PYTHAG, "√(1-x²)", 30.0, false )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x³", 0 )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 3 )
      scale.set_flags( 0 )
      scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0, true )
      scale.set_params( 2 )
      scale.add_constants( )

  strip = sheet.create_strip( 18.0, 250.0, 10.0, 15.0, 15.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0 )
      scale.set_params( 2 )
      #scale.set_overflow( 4 )
      scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "1/x", 30.0, true )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 1, true )
      scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 14.0, true )
      scale.set_params( 1 )
      #scale.set_overflow( 4 )
      scale.add_constants( )

  strip = sheet.create_strip( 24.0, 250.0, 10.0, 15.0, 15.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 30.0 )
      scale.set_params( 1 )
      scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SIN, "sin", 30.0, true )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 90, 5, [ 1, 5, 10, 20 ] )
      scale.set_flags( 0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_TAN, "tan", 30.0, true )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 45, 5, [ 1, 5, 10, 20 ] )
      scale.set_flags( 0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SINTAN, "s-t", 30.0, true )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 6, 0.5, [ 1.0 / 12.0, 0.5 ], 8 )
      scale.set_flags( 0 )

  # BUSINESS CARD like format
  sheet.create_label( "BUSINESS CARD: L P K A | B CI C | D S T ST" )
  sheet.set_style( Io::Creat::Slipstick::Style::SMALL )
  strip = sheet.create_strip( 20.0, 80.0, 5.0, 10.0, 5.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "", 0 )
      scale.set_params( 8 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "log x", 0 )
      scale.set_params( 10 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_PYTHAG, "√(1-x²)", 30.0, false )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x³", 0 )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 3 )
      scale.set_flags( 0 )
      #scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0, true )
      scale.set_params( 2 )
      #scale.add_constants( )

  strip = sheet.create_strip( 15.0, 80.0, 5.0, 10.0, 5.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0 )
      scale.set_params( 2 )
      #scale.set_overflow( 4 )
      #scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "1/x", 30.0, true )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 1, true )
      #scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 14.0, true )
      scale.set_params( 1 )
      #scale.set_overflow( 4 )
      #scale.add_constants( )

  strip = sheet.create_strip( 20.0, 80.0, 5.0, 10.0, 5.0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 30.0 )
      scale.set_params( 1 )
      #scale.add_constants( )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SIN, "sin", 30.0, true )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 90, 5, [ 1, 5, 10, 20 ] )
      scale.set_flags( 0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_TAN, "tan", 30.0, true )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 45, 5, [ 1, 5, 10, 20 ] )
      scale.set_flags( 0 )
    scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SINTAN, "s-t", 30.0, true )
      scale.set_style( Io::Creat::Slipstick::Style::SMALL )
      scale.set_params( 6, 0.5, [ 1.0 / 12.0, 0.5 ], 8 )
      scale.set_flags( 0 )

puts sheet.render( )

