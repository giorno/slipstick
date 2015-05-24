
# vim: et

require 'singleton'
require 'yaml'

module Io
  module Creat
    module Slipstick

      class I18N
        include Singleton

        def load ( file, lang = 'en' )
          @strings = YAML.load_file( file )[lang]
        end

        def string ( key )
          raise "YML file not loaded" unless not @strings.nil?
          if @strings.has_key?( key )
            return @strings[key]
          else
            $stderr.puts "Translation for key not found: " + key
            return key# failsafe
          end
        end

      end # I18N

    end # Slipstick
  end # Creat
end # Io

