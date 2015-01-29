
# vim: et

require_relative 'styled'

module Io::Creat::Slipstick
  module Backprints

    # table row
    class Tr

      public
      def initialize ( h_mm )
        @h_mm = h_mm
        @w_mm = 0
        @cells = []
      end

      public
      def td ( content, w_mm = 1, hal = Td::LEF )
        cell = Td.new( content, w_mm, hal )
        @w_mm += w_mm
        @cells << cell
        return cell
      end

      # getters
      public
      def getw ( ) return @w_mm end
      def geth ( ) return @h_mm end
      def getc ( ) return @cells end

    end # Tr

    # table cell
    class Td
      LEF = 1 # align to the left
      MID = 2 # align to the middle

      public
      def initialize ( content, w_mm, hal = LEF )
        @w_mm = w_mm
        @content = content
        @align = hal
      end

      # getters
      public
      def getw ( ) return @w_mm end
      def gett ( ) return @content end
      def geta ( ) return @align end

    end # Td

    # Basic functionality for any x*y table
    class Table < Styled

      public
      def initialize ( img, x_mm, y_mm, spacing = 0, style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::LOTICK] )
        super( style.merge( { Io::Creat::Slipstick::Key::FONT_SPACING => -0.15 } ) )
        @text_style = @text_style.merge( { "text-anchor" => "start" } )
        @img   = img
        @x_mm  = x_mm
        @y_mm  = y_mm
        @rows  = []
        @h_mm  = 0
        @w_mm  = 0
        @spacing = spacing
      end

      public
      def tr ( h_mm )
        row = Tr.new( h_mm )
        @h_mm += h_mm
        @rows << row
        return row
      end

      public
      def render ( )
        w_mm = 0
        @rows.each do | row |
          w_mm = [ w_mm, row.getw() ].max
        end
        h_mm = 0
        @rows.each_with_index do | row, index |
          cells = row.getc()
          if index > 0
            @img.line( @x_mm, @y_mm + h_mm, @x_mm + w_mm, @y_mm + h_mm, @line_style )
          end
          j_mm = 0
          cells.each_with_index do | cell, jndex |
            if jndex > 0
              @img.line( @x_mm + j_mm, @y_mm + h_mm, @x_mm + j_mm, @y_mm + h_mm + row.geth(), @line_style )
            end
            hal = cell.geta()
            @img.text( @x_mm + j_mm + ( hal == Td::MID ? cell.getw / 2 : @spacing ), @y_mm + h_mm + row.geth - ( row.geth() + @spacing - Io::Creat::Slipstick::Dim::DEFAULT[Io::Creat::Slipstick::Key::VERT_CORR][1] * @text_style["font-size"] ) / 2, cell.gett(), hal == Td::MID ? @text_style.merge( { 'text-anchor' => 'middle' } ): @text_style )
            j_mm += cell.getw()
          end
          h_mm += row.geth()
        end
        @img.rectangle( @x_mm, @y_mm, w_mm, @h_mm, @line_style )
      end

    end # Table

  end # Backprints
end # Io::Creat::Slipstick

