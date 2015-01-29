#!/usr/bin/ruby

# vim: et

require_relative 'backprint.rb'
require_relative 'table.rb'

module Io::Creat::Slipstick
  module Backprints

    # layout of Model A scales
    class ScalesBackprint < Backprint

      def render ( )
        my_mm = @y_mm - @h_mm / 2
        w_mm = @fs_mm * 2.5
        h_mm = @h_mm / 12
        fs_mm = h_mm / 1.4
        style = Io::Creat::Slipstick::Style::DEFAULT[Io::Creat::Slipstick::Entity::LOTICK].merge( { Io::Creat::Slipstick::Key::FONT_SIZE => fs_mm } )
        spacing = @fs_mm * 0.2
        tables = []
        table = Table.new( @img, @x_mm, @y_mm, spacing, style )
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
        table = Table.new( @img, @x_mm, @y_mm + 4.5 * h_mm, spacing, style )
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
        table = Table.new( @img, @x_mm, @y_mm + 8 * h_mm, spacing, style )
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
        table = Table.new( @img, @x_mm + 0.5 * h_mm + 3 * w_mm, @y_mm + 3 * h_mm, spacing, style )
          tr = table.tr( h_mm )
            td = tr.td( 'cm', 3 * w_mm )
          tables << table
        table = Table.new( @img, @x_mm + 0.5 * h_mm + 3 * w_mm, @y_mm + 4.5 * h_mm, spacing, style )
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
        table = Table.new( @img, @x_mm + 0.5 * h_mm + 3 * w_mm, @y_mm + 8 * h_mm, spacing, style )
          tr = table.tr( h_mm )
            td = tr.td( 'inches', 3 * w_mm )
          tables << table
        tables.each do | table |
          table.render()
        end
      end

    end # ScalesBackprint

  end # Backprints
end # Io::Creat::Slipstick

