#!/usr/bin/ruby

# vim: et

require_relative 'qr'
require_relative 'sheet'
require_relative 'gr_trigon'
require_relative 'gr_table'

module Io::Creat::Slipstick
  module Model

    # model A inspired by layout of LOGAREX 27403-II
    class A < Io::Creat::Slipstick::Layout::Sheet
      # layers to generate
      LAYER_FACE    = 0x1 # front side (page) of a printout list
      LAYER_REVERSE = 0x2 # reverse side of the printout`
      LAYER_STOCK   = 0x4 # generate stator if set, slide if not set

      # branding/version texts on the stock face
      STYLE_BRAND   = { "font-size" => "2.4",
                        "font-family" => "Slipstick Sans Mono",
                        "font-weight" => "normal",
                        "fill" => "#f57900",
                        "text-anchor" => "middle" }
      # QR code style
      STYLE_QR      = { :fill => "black", :stroke_width => "0.01", :stroke => "black" }

      public
      def initialize ( layers = LAYER_FACE | LAYER_REVERSE )
        super()
        @layers = layers
        @hu_mm = 22.0 # height of upper half of stator strip
        @hl_mm = 22.0 # height of lower half of stator strip
        @hs_mm = 18.0 # height of slipstick strip
        @t_mm  = 2.0 # thickness of the slipstick
        @sh_mm = @h_mm # sheet height
        @h_mm  = @hu_mm + @hl_mm + @hs_mm
        @x_mm  = 5.0
        @y_mm  = 10.0
        @w_mm  = 287.0
        @b_mm  = 0.1 # bending radius (approximated)
        @cs_mm = 0.5 # correction for slide height

        w_m_mm = 250.0
        w_l_mm = 7.0
        w_s_mm = 23.0
        w_a_mm = 7.0

        # scales of the stator
        if ( ( @layers & LAYER_STOCK ) != 0 ) and ( ( @layers & LAYER_FACE ) != 0 )
          # bottom stock strip
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

          # top of the stock back
          strip = create_strip( @x_mm, @y_mm + @t_mm + @hl_mm, 8, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "cm", 0.33 )
              scale.set_params( 25 )
              scale.set_overflow( @b_mm )

          # bottom of the stock back
          strip = create_strip( @x_mm, @y_mm + @t_mm + @h_mm + @hl_mm - 8, 8, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_INCH, "inches", 0.33, true )
              scale.set_params( 10 )
              scale.set_overflow( @b_mm )

          # top stock strip
          strip = create_strip( @x_mm, @y_mm + 2 * @t_mm + @h_mm + @hu_mm, @hu_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LIN_DECIMAL, "log", 0.33 )
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
          strip = create_strip( @x_mm, @y_mm + ( ( @h_mm - @hs_mm ) / 2 ), @hs_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e⁰·⁰¹ˣ", 0.5 )
              scale.set_params( 100 )
              scale.set_overflow( 4.0 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e⁰·¹ˣ", 0.33, true )
              scale.set_style( Io::Creat::Slipstick::Style::SMALL )
              scale.set_params( 10 )
            scale = strip.create_scale( Io::Creat::Slipstick::ScaleType::LOG_POWER, "e¹ˣ", 0.5, true )
              scale.set_params( 1 )
              scale.set_overflow( 4.0 )

          strip = create_strip( @x_mm, ( ( @h_mm - @hs_mm ) / 2 ) + @y_mm + 2 * @t_mm + @h_mm + @hu_mm + @hl_mm, @hs_mm, w_m_mm, w_l_mm, w_s_mm, w_a_mm )
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
        @img.rectangle( "%g" % x, "%g" % y, "%g" % w, "%g" % h, @style )
      end

      private
      def line ( x1, y1, x2, y2 )
        @img.line( "%g" % x1, "%g" % y1, "%g" % x2, "%g" % y2, @style )
      end

      private
      def text ( x, y, string, style )
        @img.text( "%g" % x, "%g" % y, string, style )
      end

      private
      def qr ( label )
      end

      # render strips and edges for cutting/bending
      public
      def render()
        @style = { :stroke_width => "0.1", :stroke => "#aaaaaa", :stroke_cap => "square", :fill => "none" }
        # stock lines are intentionally positioned upside down (in landscape)
        if ( @layers & LAYER_STOCK ) != 0
          if ( @layers & LAYER_REVERSE ) != 0
            # cutting guidelines for the stator
            rect( @x_mm, @sh_mm - ( @y_mm + @hu_mm + 2 * @t_mm + @h_mm + @hl_mm ), @w_mm, @hu_mm + 2 * @t_mm + @h_mm + @hl_mm )
            # bending guidelines for the stator
            line( @x_mm, @sh_mm - ( @y_mm + @hu_mm ), @x_mm + @w_mm, @sh_mm - ( @y_mm + @hu_mm ) )
            line( @x_mm, @sh_mm - ( @y_mm + @hu_mm + @t_mm ), @x_mm + @w_mm, @sh_mm - ( @y_mm + @hu_mm + @t_mm ) )
            line( @x_mm, @sh_mm - ( @y_mm + @hu_mm + @t_mm + @h_mm ), @x_mm + @w_mm, @sh_mm - ( @y_mm + @hu_mm + @t_mm + @h_mm ) )
            line( @x_mm, @sh_mm - ( @y_mm + @hu_mm + 2 * @t_mm + @h_mm ), @x_mm + @w_mm, @sh_mm - ( @y_mm + @hu_mm + 2 * @t_mm + @h_mm ) )
          else
            # branding texts
            text( @x_mm + 174, @y_mm + 106, "creat.io MODEL A", STYLE_BRAND )
            # sin-cos help
            bottom_off_mm = 15.0
            bottom_mm = @y_mm + bottom_off_mm + @hl_mm + @t_mm
            gr_size_mm = @h_mm - ( 2 * bottom_off_mm )
            gr = Io::Creat::Slipstick::Graphics::Trigonometric.new( @img, gr_size_mm, 2 * bottom_off_mm, bottom_mm )

            # table of scale labels
            bp = ConstantsBackprint.new( @img, 3 * bottom_off_mm + gr_size_mm, bottom_mm, gr_size_mm )
            bp.render()
            # QR code
            qr = Qr.new( @img, 'http://www.creat.io/slipstick', 4, :h, @x_mm + @w_mm - gr_size_mm - bottom_off_mm, bottom_mm, gr_size_mm, STYLE_QR )
          end
        end
        if ( ( @layers & LAYER_STOCK ) == 0 ) and ( ( @layers & LAYER_FACE ) != 0 )
          # cutting guidelines for the slipstick
          line( 0, @y_mm + @cs_mm, 297, @y_mm + @cs_mm )
          line( 0, @y_mm + @h_mm - @cs_mm, 297, @y_mm + @h_mm - @cs_mm )
          line( 0, @y_mm + @hu_mm + 2 * @t_mm + @h_mm + @hl_mm + @cs_mm, 297, @y_mm + @hu_mm + 2 * @t_mm + @h_mm + @hl_mm + @cs_mm )
          line( 0, @y_mm + @hu_mm + 2 * @t_mm + 2 * @h_mm + @hl_mm - @cs_mm, 297, @y_mm + @hu_mm + 2 * @t_mm + 2 * @h_mm + @hl_mm - @cs_mm )
        end
        # strips
        super( true )
        @img.close()
        return @img.output
      end

      # common properties and functionality of graphical helpers printed on the
      # back of the stock
      class Backprint

        public
        def initialize ( img, x_mm, y_mm, h_mm, w_mm = nil )
          @img   = img
          @x_mm  = x_mm
          @y_mm  = y_mm
          @h_mm  = h_mm
          @w_mm  = w_mm.nil? ? h_mm : w_mm
          # font size for given backprint height
          # other graphics dimensions may be calculated from it
          @fs_mm = @h_mm / ( 5 * 3.5 )
        end

       public
        def getfs ( )
        end

      end # Backprint

      #class QrBackprint < Backprint

      #  def initialize ( img, text, size, level, x_mm, y_mm, size_mm, style )
      #    super( img, x_mm, y_mm, size_mm )
      #    @qr = Qr.new( @img, text, size, level, @x_mm, @y_mm, @size_mm, style )
      #  end

      #  def render ()
      #    qr.render()
      #  end

      #end # QrBackprint

      class ScalesBackprint < Backprint

      def render ( )
        my_mm = @y_mm - @h_mm / 2
        w_mm = @fs_mm * 2.5
        #h_mm = 1.4 * @fs_mm
        h_mm = @h_mm / 12
        fs_mm = h_mm / 1.4
        style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::LOTICK].merge( { Io::Creat::Slipstick::Key::FONT_SIZE => fs_mm } )
        spacing = @fs_mm * 0.2
        tables = []
        table = Io::Creat::Slipstick::Graphics::Table.new( @img, @x_mm, @y_mm, spacing, style )
          tr = table.tr( h_mm )
            td = tr.td( 'L', w_mm )
            td = tr.td( 'log', 2 * w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'P', w_mm )
            td = tr.td( '√1-x²', w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'K', w_mm )
            td = tr.td( 'x³', w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'A', w_mm )
            td = tr.td( 'x²', w_mm )
          tables << table
        table = Io::Creat::Slipstick::Graphics::Table.new( @img, @x_mm, @y_mm + 4.5 * h_mm, spacing, style )
          tr = table.tr( h_mm )
            td = tr.td( 'B', w_mm )
            td = tr.td( 'x²', 2 * w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'CI', w_mm )
            td = tr.td( '1/x', w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'C', w_mm )
            td = tr.td( 'x', w_mm )
          tables << table
        table = Io::Creat::Slipstick::Graphics::Table.new( @img, @x_mm, @y_mm + 8 * h_mm, spacing, style )
          tr = table.tr( h_mm )
            td = tr.td( 'D', w_mm )
            td = tr.td( 'x', 2 * w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'S', w_mm )
            td = tr.td( 'sin', w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'T', w_mm )
            td = tr.td( 'tan', w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'ST', w_mm )
            td = tr.td( 'sin-tan', w_mm )
          tables << table
        table = Io::Creat::Slipstick::Graphics::Table.new( @img, @x_mm + 0.5 * h_mm + 3 * w_mm, @y_mm + 3 * h_mm, spacing, style )
          tr = table.tr( h_mm )
            td = tr.td( 'cm', 3 * w_mm )
          tables << table
        table = Io::Creat::Slipstick::Graphics::Table.new( @img, @x_mm + 0.5 * h_mm + 3 * w_mm, @y_mm + 4.5 * h_mm, spacing, style )
          tr = table.tr( h_mm )
            td = tr.td( 'LL1', w_mm )
            td = tr.td( 'e⁰·⁰¹ˣ', 2 * w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'LL2', w_mm )
            td = tr.td( 'e⁰·¹ˣ', w_mm )
          tr = table.tr( h_mm )
            td = tr.td( 'LL3', w_mm )
            td = tr.td( 'e¹ˣ', w_mm )
          tables << table
        table = Io::Creat::Slipstick::Graphics::Table.new( @img, @x_mm + 0.5 * h_mm + 3 * w_mm, @y_mm + 8 * h_mm, spacing, style )
          tr = table.tr( h_mm )
            td = tr.td( 'inches', 3 * w_mm )
          tables << table
        tables.each do | table |
          table.render()
        end
      end

      end # ScalesBackprint

      class ConstantsBackprint < Backprint
      CONSTANTS =  [ [ 'imaginary',       'i²', '-1' ],
                     [ 'Meissel–Mertens', 'M₁', '0.26149 72128' ],
                     [ 'Omega',           'Ω',  '0.56714 32904' ],
                     [ 'Euler-Mascheroni', 'γ', '0.57721 56649' ],
                     [ 'Apéry',            'ζ', '1.20205 69032' ],
                     [ 'Pythagoras',       "\u221b2", '1.41421 35624' ],
                     [ 'Ramanujan-Soldner', 'μ', '1.45136 92349' ],
                     [ 'Golden ration', 'φ', '1.61803 39887' ],
                     [ 'Theodorus', "\u221b3", '1.73205 08076' ],
                     [ '', "\u221b5", '2.23606 79775' ],
                     [ 'Euler', 'e', '2.71828 18285' ],
                     [ 'Archimedes', 'π', '3.14159 26536' ],
                     [ 'Reciprocal Fibonacci', 'ψ', '3.35988 56662' ],
                   ]
      def render ( )
        my_mm = @y_mm - @h_mm / 2
        w_mm = @fs_mm * 2.5
        #h_mm = 1.4 * @fs_mm
        h_mm = @h_mm / 12
        fs_mm = h_mm / 1.6
        style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::LOTICK].merge( { Io::Creat::Slipstick::Key::FONT_SIZE => fs_mm } )
        spacing = @fs_mm * 0.2
        tables = []
        table = Io::Creat::Slipstick::Graphics::Table.new( @img, @x_mm, @y_mm, spacing, style )
        CONSTANTS.each do | constant |
          tr = table.tr( h_mm )
            td = tr.td( constant[0], 5 * w_mm )
            td = tr.td( constant[1], 1 * w_mm )
            td = tr.td( constant[2], 4 * w_mm )
        end
        tables << table
        tables.each do | table |
          table.render()
        end
      end

      end # ConstantsBackprint

      class SinCosBackprint < Backprint
      end # SinCosBackprint

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

