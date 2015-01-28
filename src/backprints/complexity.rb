
require_relative '../constants'

module Io::Creat::Slipstick
  module Backprints

    class Complexity < Backprint
      FUNCTIONS = [ 'O(n)'     => Proc.new{ | n | n },
                    'O(log n)' => Proc.new{ | n | Math::log2( n ) },
                    'O(n log n' => Proc.new{ | n | n * Math::log2( n ) },
                  ]
    end # Complexity

  end # Backprints
end # Io::Creat::Slipstick
