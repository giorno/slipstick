#!/usr/bin/ruby

require 'rqrcode'
require_relative 'constants'

module Io::Creat::Slipstick

  # renders QR code onto Rasem SVG canvas
  class Qr
    DENSITY = { 1 => 21.0, 2 => 25.0, 3 => 29.0, 4 => 33.0, 10 => 57.0, 25 => 117.0, 40 => 177.0 }

    public
    def initialize ( img, text, size, level, x_mm, y_mm, size_mm, style )
      qr = RQRCode::QRCode.new( text, :size => size, :level => level )
      @img = img
      @scale = size_mm / DENSITY[ size ]
      qr.modules.each_index do |x|
        qr.modules.each_index do |y|
          if qr.dark?( x, y )
            @img.rectangle( "%gmm" % ( x_mm + x * @scale ),
                            "%gmm" % ( y_mm + y * @scale ),
                            "%gmm" % @scale,
                            "%gmm" % @scale,
                            style )
          end
        end
      end
    end

  end # Qr

end # Io::Creat::Slipstick

