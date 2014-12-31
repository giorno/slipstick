#!/usr/bin/ruby

require_relative 'sheet'

module Io::Creat::Slipstick
  module Model

    class A < Io::Creat::Slipstick::Layout::Sheet

      public
      def initialize ( )
        super()
        @hu_mm = 22.0 # height of upper half of stator strip
        @hl_mm = 22.0 # height of lower half of stator strip
        @hs_mm = 18.0 # height of slipstick strip
        @t_mm  = 1.0 # thickness of the slipstick
        @h_mm  = @hu_mm + @hl_mm + @hs_mm
        @x_mm  = 5.0
        @y_mm  = 5.0
        @w_mm  = 287.0

        w_m_mm = 260.0
        w_l_mm = 7.0
        w_s_mm = 13.0
        w_a_mm = 7.0

        strip = create_strip( @x_mm, @y_mm, @hl_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
          scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_DECIMAL, "x", 0.5 )
            scale.set_params( 1 )
            scale.add_constants( )
            #scale.set_overflow( 2.0 )
          scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SIN, "sin", 0.33, true )
            scale.set_style( Io::Creat::Slipstick::Style::SMALL )
            scale.set_params( 90, 5, [ 1, 5, 10, 20 ] )
            scale.set_flags( 0 )
          scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_TAN, "tan", 0.33, true )
            scale.set_style( Io::Creat::Slipstick::Style::SMALL )
            scale.set_params( 45, 5, [ 1, 5, 10, 20 ] )
            scale.set_flags( 0 )
          scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_SINTAN, "s-t", 0.33, true )
            scale.set_style( Io::Creat::Slipstick::Style::SMALL )
            scale.set_params( 6, 0.5, [ 1.0 / 12.0, 0.5 ], 8 )
            scale.set_flags( 0 )

        strip = create_strip( @x_mm, @y_mm + @t_mm + @hl_mm, 8, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
          scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "cm", 0.33 )
            scale.set_params( 26 )

        strip = create_strip( @x_mm, @y_mm + @t_mm + @h_mm + @hl_mm - 8, 8, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
          scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_INCH, "in", 0.33, true )
            scale.set_params( 10 )

        strip = create_strip( @x_mm, @y_mm + 2 * @t_mm + @h_mm + @hu_mm, @hu_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
          scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "log x", 0.33 )
            scale.set_params( 10 )
          scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::TGN_PYTHAG, "√(1-x²)", 0.33 )
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
            #scale.set_overflow( 2.0 )

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
      
      # allows to create strip with absolute positioning
      private
      def create_strip( x_mm, y_mm, h_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
        strip = super( h_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
        strip.instance_variable_set( :@off_x_mm, x_mm )
        strip.instance_variable_set( :@off_y_mm, y_mm )
        return strip
      end

      private
      def rect ( x1, y1, x2, y2 )
        @img.rectangle( "%gmm" % x1, "%gmm" % y1, "%gmm" % x2, "%gmm" % y2, { :fill => "none", :stroke => "black", :stroke_width => "0.1mm" } )
      end

      # render strips and edges for cutting/bending
      public
      def render()
        # cutting guidelines
        rect( @x_mm, @y_mm, @w_mm, @hu_mm )
        rect( @x_mm, @y_mm + @hu_mm + @t_mm, @w_mm, @h_mm )
        rect( @x_mm, @y_mm + @hu_mm + 2 * @t_mm + @h_mm, @w_mm, @hl_mm )
        rect( @x_mm, @y_mm + @hu_mm + 2 * @t_mm + @h_mm + @hl_mm + @y_mm, @w_mm, @h_mm )
        
        # strips
        return super()
      end

    end # A

  end # Model
end # Io::Creat::Slipstick

a = Io::Creat::Slipstick::Model::A.new()
puts a.render()
