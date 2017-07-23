#!/usr/bin/ruby

# Script executing a single build step producing an SVG for printout of a single
# slipstick component.

def usage ( )
  $stderr.puts "Usage: #{$0} <style> <lang> <stator|slide-math|transp> [both|face|reverse]\n\nOutputs SVG for given element and printout side.\n"
  $stderr.puts " style       .. name of the style to use, supported: default, colored"
  $stderr.puts " lang        .. language code for internationalized strings, supported: en, sk"
  $stderr.puts " stator      .. stock element of slide rule (static)"
  $stderr.puts " slide-math  .. sliding element of slide rule for mathematic operations"
  $stderr.puts " transp      .. transparent elements (tracing paper)"
  $stderr.puts " both        .. generate both sides of the printout"
  $stderr.puts " face        .. generate face side of the printout"
  $stderr.puts " reverse     .. generate reverse side of the printout"
end

component = 0
layer = 0
if ARGV.length <= 2
  usage( )
  exit
end

# retrieve the style
if ARGV.length >= 2
  if ['default', 'colored'].include? ARGV[0]
    # sets Io::Creat::Slipstick::STYLE
    require_relative File.join( 'style', ARGV[0] )
  else
    usage
  end
end

require_relative 'model_a_composite'

if ARGV.length >= 3
  lang = ARGV[1]
  if ARGV[2] == 'stock'
    component = Io::Creat::Slipstick::Model::A::COMP_STOCK
  elsif ARGV[2] == 'slide-math'
    component = Io::Creat::Slipstick::Model::A::COMP_SLIDE_MATH
  elsif ARGV[2] == 'slide-photo'
    component = Io::Creat::Slipstick::Model::A::COMP_SLIDE_PHOTO
  elsif ARGV[2] == 'transp'
    component = Io::Creat::Slipstick::Model::A::COMP_TRANSP
  else
    usage
  end
end

if ARGV.length > 3
  if ARGV[3] == 'face'
    layer |= Io::Creat::Slipstick::Model::Component::LAYER_FACE
  elsif ARGV[3] == 'reverse'
    layer |= Io::Creat::Slipstick::Model::Component::LAYER_REVERSE
  elsif ARGV[3] == 'both'
    layer |= Io::Creat::Slipstick::Model::Component::LAYER_FACE | Io::Creat::Slipstick::Model::Component::LAYER_REVERSE
  else
    usage
    exit
  end
end

Io::Creat::Slipstick::I18N.instance.load( 'src/model_a.yml', lang )
a = Io::Creat::Slipstick::Model::A.new( component, layer, Io::Creat::Slipstick::STYLE )
puts a.render()

