#!/usr/bin/ruby

require 'rqrcode'
require_relative 'constants'
require_relative 'backprints/backprint'

module Io::Creat::Slipstick

  # renders QR code onto Rasem SVG canvas
  class Qr < Io::Creat::Slipstick::Backprints::Backprint
    # mapping of QR size (version) to number of squares per dimension
    DENSITY = { 1 => 21.0, 2 => 25.0, 3 => 29.0, 4 => 33.0, 10 => 57.0, 25 => 117.0, 40 => 177.0 }

    # style violates the Backprint contract
    public
    def initialize ( img, text, size, level, x_mm, y_mm, size_mm, style )
      super( img, x_mm, y_mm, size_mm )
      @qr = RQRCode::QRCode.new( text, :size => size, :level => level )
      @style = style
      @scale = size_mm / DENSITY[ size ]
    end # initialize

    public
    def render ( )
      @qr.modules.each_index do |x|
        @qr.modules.each_index do |y|
          if @qr.qrcode.checked?( x, y )
            @img.rectangle( "%g" % ( @x_mm + y * @scale ),
                            "%g" % ( @y_mm + x * @scale ),
                            "%g" % @scale,
                            "%g" % @scale,
                            @style )
          end
        end
      end
    end # render

  end # Qr

end # Io::Creat::Slipstick

