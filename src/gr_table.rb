
# vim: et

require_relative 'gr_style'

module Io::Creat::Slipstick
  module Graphics

    # table row
    class Tr

      public
      def initialize ( h_mm )
        @h_mm = h_mm
        @w_mm = 0
        @cells = []
      end

      public
      def td ( content, w_mm = 1 )
        cell = Td.new( content, w_mm )
        @w_mm += w_mm
        @cells << cell
        return cell
      end

      public
      def getw ( )
        return @w_mm
      end

      public
      def geth ( )
        return @h_mm
      end

      public
      def getc ( )
        return @cells
      end

    end # Tr

    # table cell
    class Td

      public
      def initialize ( content, w_mm, hal = "start", tal = "middle" )
        @w_mm = w_mm
        @content = content
      end

      public
      def getw ( )
        return @w_mm
      end

      public
      def gett ( )
        return @content
      end

    end # Td

    # Basic functionality for any x*y table
    class Table < Styled

      public
      def initialize ( img, x_mm, y_mm, spacing = 0, style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::LOTICK] )
        super( style )
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
            @img.text( @x_mm + j_mm + @spacing, @y_mm + h_mm + row.geth - ( row.geth() + @spacing - Io::Creat::Slipstick::Dim::DEFAULT[Io::Creat::Slipstick::Key::VERT_CORR][1] * @text_style["font-size"] ) / 2, cell.gett(), @text_style )
            j_mm += cell.getw()
          end
          h_mm += row.geth()
        end
        @img.rectangle( @x_mm, @y_mm, w_mm, @h_mm, @line_style )
      end

    end # Table

  end # Graphics
end # Io::Creat::Slipstick

