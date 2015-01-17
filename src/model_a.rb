#!/usr/bin/ruby

require_relative 'sheet'

module Io::Creat::Slipstick
  module Model

    class A < Io::Creat::Slipstick::Layout::Sheet
      LAYER_FACE    = 0x1 # side of a printout list
      LAYER_REVERSE = 0x2
      LAYER_STOCK   = 0x4 # stator, slide if not set

      public
      def initialize ( layers = LAYER_FACE | LAYER_REVERSE )
        super()
        @layers = layers
        @hu_mm = 22.0 # height of upper half of stator strip
        @hl_mm = 22.0 # height of lower half of stator strip
        @hs_mm = 18.0 # height of slipstick strip
        @t_mm  = 1.0 # thickness of the slipstick
        @h_mm  = @hu_mm + @hl_mm + @hs_mm
        @x_mm  = 5.0
        @y_mm  = 5.0
        @w_mm  = 287.0
        @b_mm  = 0.1 # bending radius (approximated)

        w_m_mm = 250.0
        w_l_mm = 7.0
        w_s_mm = 23.0
        w_a_mm = 7.0

        # scales of the stator
        if ( ( @layers & LAYER_STOCK ) != 0 ) and ( ( @layers & LAYER_FACE ) != 0 )
          strip = create_strip( @x_mm, @y_mm, @hl_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 0.5 )
              scale.set_params( 1 )
              scale.add_constants( )
              scale.set_overflow( 1.0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SIN, "sin", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 90, 5, [ 1, 5, 10, 20 ] )
              scale.set_flags( 0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_TAN, "tan", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 45, 5, [ 1, 5, 10, 20 ] )
              scale.set_flags( 0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SINTAN, "sin-tan", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 6, 0.5, [ 1.0 / 12.0, 0.5 ], 8 )
              scale.set_flags( 0 )
              scale.set_overflow( @b_mm )

          strip = create_strip( @x_mm, @y_mm + @t_mm + @hl_mm, 8, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "cm", 0.33 )
              scale.set_params( 25 )
              scale.set_overflow( @b_mm )

          strip = create_strip( @x_mm, @y_mm + @t_mm + @h_mm + @hl_mm - 8, 8, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_INCH, "inches", 0.33, true )
              scale.set_params( 10 )
              scale.set_overflow( @b_mm )

          strip = create_strip( @x_mm, @y_mm + 2 * @t_mm + @h_mm + @hu_mm, @hu_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "log x", 0.33 )
              scale.set_params( 10 )
              scale.set_overflow( @b_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_PYTHAG, "√1-x²", 0.33 )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x³", 0.33 )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 3 )
              scale.set_flags( 0 )
              scale.add_constants( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0.5, true )
              scale.set_params( 2 )
              scale.add_constants( )
              scale.set_overflow( 1.0 )
        end

        # sides of the slide
        if ( ( @layers & LAYER_STOCK ) == 0 ) and ( ( @layers & LAYER_REVERSE ) == 0 )
          strip = create_strip( @x_mm, 2 * @y_mm + ( ( @h_mm - @hs_mm ) / 2 ), @hs_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e⁰·⁰¹ˣ", 0.5 )
              scale.set_params( 100 )
              scale.set_overflow( 4.0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e⁰·¹ˣ", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 10 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e¹ˣ", 0.5, true )
              scale.set_params( 1 )
              scale.set_overflow( 4.0 )

          strip = create_strip( @x_mm, ( ( @h_mm - @hs_mm ) / 2 ) + 2 * @y_mm + 2 * @t_mm + @h_mm + @hu_mm + @hl_mm, @hs_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x²", 0.5 )
              scale.set_params( 2 )
              scale.set_overflow( 4.0 )
              scale.add_constants( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "1/x", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 1, true )
              scale.add_constants( )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 0.5, true )
              scale.set_params( 1 )
              scale.set_overflow( 4.0 )
              scale.add_constants( )
        end
      end
      
      # allows to create strip with absolute positioning
      private
      def create_strip( x_mm, y_mm, h_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
        strip = super( h_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
        strip.instance_variable_set( :@off_x_mm, x_mm )
        strip.instance_variable_set( :@off_y_mm, y_mm )
        return strip
      end

      private
      def rect ( x, y, w, h )
        @img.rectangle( "%gmm" % x, "%gmm" % y, "%gmm" % w, "%gmm" % h, @style )
      end

      private
      def line ( x1, y1, x2, y2 )
        @img.line( "%gmm" % x1, "%gmm" % y1, "%gmm" % x2, "%gmm" % y2, @style )
      end

      # render strips and edges for cutting/bending
      public
      def render()
        @style = { :stroke_width => "0.1mm", :stroke => "#aaaaaa", :stroke_cap => "square", :fill => "none" }
        if ( ( @layers & LAYER_STOCK ) != 0 ) and ( ( @layers & LAYER_REVERSE ) != 0 )
          # cutting guidelines for the stator
          rect( @x_mm, @y_mm, @w_mm, @hu_mm + 2 * @t_mm + @h_mm + @hl_mm )
          # bending guidelines for the stator
          line( @x_mm, @y_mm + @hu_mm, @x_mm + @w_mm, @y_mm + @hu_mm )
          line( @x_mm, @y_mm + @hu_mm + @t_mm, @x_mm + @w_mm, @y_mm + @hu_mm + @t_mm )
          line( @x_mm, @y_mm + @hu_mm + @t_mm + @h_mm, @x_mm + @w_mm, @y_mm + @hu_mm + @t_mm + @h_mm )
          line( @x_mm, @y_mm + @hu_mm + 2 * @t_mm + @h_mm, @x_mm + @w_mm, @y_mm + @hu_mm + 2 * @t_mm + @h_mm )
        end
        if ( ( @layers & LAYER_STOCK ) == 0 ) and ( ( @layers & LAYER_FACE ) != 0 )
          # cutting guidelines for the slipstick
          line( 0, 2 * @y_mm, 297, 2 * @y_mm )
          line( 0, 2 * @y_mm + @h_mm, 297, 2 * @y_mm + @h_mm )
          line( 0, @y_mm + @hu_mm + 2 * @t_mm + @h_mm + @hl_mm + @y_mm, 297, @y_mm + @hu_mm + 2 * @t_mm + @h_mm + @hl_mm + @y_mm )
          line( 0, @y_mm + @hu_mm + 2 * @t_mm + 2 * @h_mm + @hl_mm + @y_mm, 297, @y_mm + @hu_mm + 2 * @t_mm + 2 * @h_mm + @hl_mm + @y_mm )
        end
        # strips
        return super()
      end

    end # A

  end # Model
end # Io::Creat::Slipstick

def usage ( )
  $stderr.puts "Usage: #{$0} <stator|slide>> [both|face|reverse]\n\nOutputs SVG for requested side of the slide rule printout."
end

layers = 0
if ARGV.length == 0
  usage( )
  raise "Requires either 'stock' or 'slide' as first parameter"
end

if ARGV.length >= 1
  if ARGV[0] == 'stock'
    layers = Io::Creat::Slipstick::Model::A::LAYER_STOCK
  elsif ARGV[0] != 'slide'
    usage( )
  end
end

if ARGV.length > 1
  if ARGV[1] == 'face'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_FACE
  elsif ARGV[1] == 'reverse'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_REVERSE
  elsif ARGV[1] != 'both'
    layers |= Io::Creat::Slipstick::Model::A::LAYER_FACE | Io::Creat::Slipstick::Model::A::LAYER_REVERSE
    $stderr.puts "Usage: #{$0} <stator|slide>> [both|face|reverse]\n\nOutputs SVG for requested side of the slide rule printout."
    exit
  end
end

a = Io::Creat::Slipstick::Model::A.new( layers )
puts a.render()

