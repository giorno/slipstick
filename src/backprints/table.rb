
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

      # build a table cell entity
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

    # basic functionality for any x*y table
    class Table < Styled

      ORIENT_PORTRAIT = 0
      ORIENT_LANDSCAPE = 1

      public
      def initialize ( img, x_mm, y_mm, spacing = 0, orient = ORIENT_PORTRAIT, style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::SCALE] )
        super( style )
        @text_style = @text_style.merge( { "text-anchor" => "start" } )
        @img        = img
        @x_mm       = x_mm
        @y_mm       = y_mm
        @rows       = []
        @h_mm       = 0
        @w_mm       = 0
        @spacing    = spacing
        @orient     = orient
      end

      # build a table row entity
      public
      def tr ( h_mm )
        row = Tr.new( h_mm )
        @h_mm += h_mm
        @rows << row
        return row
      end

      # compute values for rendering
      private
      def reorient ( )
        @w_mm = 0
        @rows.each do | row |
          @w_mm = [ @w_mm, row.getw() ].max
        end

        if @orient == ORIENT_LANDSCAPE
          @y_mm += @w_mm # move Y-coord to fix left top corner
        end
      end

      def line( x1_mm, y1_mm, x2_mm, y2_mm )
        if @orient == ORIENT_LANDSCAPE
          @img.line( @x_mm + y1_mm, @y_mm - x1_mm, @x_mm + y2_mm, @y_mm - x2_mm, @line_style )
        else
          @img.line( @x_mm + x1_mm, @y_mm + y1_mm, @x_mm + x2_mm, @y_mm + y2_mm, @line_style )
        end
      end

      def text( x_mm, y_mm, label, style )
        if @orient == ORIENT_LANDSCAPE
          @img.rtext( @x_mm + y_mm, @y_mm - x_mm, -90, label, style )
        else
          @img.text( @x_mm + x_mm, @y_mm + y_mm, label, style )
        end
      end

      public
      def render ( )
        reorient()
        h_mm = 0
        @rows.each_with_index do | row, index |
          cells = row.getc()
          if index > 0
            line( 0, h_mm, @w_mm, h_mm )
          end
          j_mm = 0
          cells.each_with_index do | cell, jndex |
            if jndex > 0
              line( j_mm, h_mm, j_mm, h_mm + row.geth() )
            end
            hal = cell.geta()
            text( j_mm + ( hal == Td::MID ? cell.getw / 2 : @spacing ), h_mm + row.geth - ( row.geth() + @spacing - Io::Creat::Slipstick::Dim::DEFAULT[Io::Creat::Slipstick::Key::VERT_CORR][1] * @text_style[:font_size] ) / 2, cell.gett(), hal == Td::MID ? @text_style.merge( { 'text-anchor' => 'middle' } ): @text_style )
            j_mm += cell.getw()
          end
          h_mm += row.geth()
        end

        if @orient == ORIENT_LANDSCAPE
          @img.rectangle( @x_mm, @y_mm - @w_mm, @h_mm, @w_mm, @line_style )
        else
          @img.rectangle( @x_mm, @y_mm, @w_mm, @h_mm, @line_style )
        end
      end

    end # Table

  end # Backprints
end # Io::Creat::Slipstick

