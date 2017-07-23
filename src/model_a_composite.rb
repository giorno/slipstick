# vim: et

require_relative 'backprints/bu_scales'
require_relative 'backprints/constants'
require_relative 'backprints/conv'
require_relative 'backprints/instr'
require_relative 'backprints/log'
require_relative 'backprints/pageno'
require_relative 'backprints/scales'
require_relative 'backprints/trigon'

require_relative 'i18n'
require_relative 'model_a_component.rb'
require_relative 'model_a_slide_math.rb'
require_relative 'model_a_slide_photo.rb'
require_relative 'model_a_stock.rb'
require_relative 'model_a_transparent.rb'
require_relative 'qr'
require_relative 'sheet'

include Io::Creat
include Io::Creat::Slipstick::Backprints

module Io::Creat::Slipstick
  module Model

    # Builder of the model A of the slipstick inspired by layout of LOGAREX 27403-II.
    class A < Io::Creat::Slipstick::Layout::Sheet
      attr_accessor :dm, :img, :style, :bprints, :i18n, :branding

      # component specifier
      COMP_STOCK       = 0x1 # generate stator and cursor elements
      COMP_SLIDE_MATH  = 0x2 # generate math slide element
      COMP_SLIDE_PHOTO = 0x4 # generate photo slide elements
      COMP_TRANSP      = 0x8 # generate transparent elements

      public
      def initialize ( component, layer, style )
        super()
        set_style( style )
        raise "Component must be one of COMP_STOCK, COMP_SLIDE_MATH or COMP_TRANSP" unless [ COMP_STOCK, COMP_SLIDE_MATH, COMP_SLIDE_PHOTO, COMP_TRANSP ].include?( component )
        @i18n = Io::Creat::Slipstick::I18N.instance
        @img.pattern( 'glued', 3 )
        # branding/version texts
        @branding = Branding.new
          @branding.release = true
          @branding.brand = "CREAT.IO"
          @branding.model = "SR-M1A2"
          @branding.height = 2.2
          @branding.pattern = "1, 1" # line pattern for bent edges
          if @branding.release
            @branding.version = "%s %s" % [ @i18n.string( 'slide_rule'), @branding.model ]
          else
            @branding.version = "ts0x%s" % Time.now.getutc().to_i().to_s( 16 )
          end
        @comp = component # todo temporary placeholder
        @layer = layer
        @dm = Dimensions.new( @h_mm, @w_mm )

        # prepare style for smaller scales
        @style_aux = Io::Creat::svg_dec_style_units( @style[Io::Creat::Slipstick::Entity::AUX], SVG_STYLE_TEXT )

        if ( component == COMP_STOCK )
          @component = Stock.new( self, @layer )
        elsif ( component == COMP_SLIDE_MATH )
          @component = MathSlide.new( self, @layer )
        elsif ( component == COMP_SLIDE_PHOTO )
          @component = PhotoSlide.new( self, @layer )
        elsif ( component == COMP_TRANSP )
          @component = Transparent.new( self, @layer )
        end
      end
      
      # allows to create strip with absolute positioning
      public
      def create_strip( x_mm, y_mm, h_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
        strip = super( h_mm, w_mainscale_mm, w_label_mm, w_subscale_mm, w_after_mm )
        strip.instance_variable_set( :@off_x_mm, x_mm )
        strip.instance_variable_set( :@off_y_mm, y_mm )
        return strip
      end

      public
      def render_cursor ( y_mm, dir )
        if dir == -1 then y_mm -= @dm.cw_mm end
        s_mm = @dm.ct_mm + @dm.b_mm
        b_mm = 15.0 # overlap
        rw_mm = 2 * @dm.ch_mm + b_mm + 2 * s_mm # projected width of rectangle
        x_mm = @dm.x_mm + ( @dm.w_mm - rw_mm ) / 2
        if ( @layer & Component::LAYER_FACE ) != 0
          # instructions
          off = 0.05
          csr = InstructionsBackprint.new( @img, x_mm + rw_mm - @dm.ch_mm + @dm.ch_mm * off, y_mm + @dm.ch_mm * off, @dm.ch_mm * ( 1 - 2 * off ) )
          csr.setw( @dm.cw_mm - @dm.ch_mm * 2 * off )
          csr.render()
          # contour
          dm = @dm
          @img.path( @style.clone ) do
            moveToA( x_mm, y_mm )
            hlineToA( x_mm + b_mm + s_mm )
            # circular cutout
            arcToA( x_mm + b_mm + s_mm + dm.ch_mm, y_mm, 0.75 * dm.ch_mm, 0.75 * dm.ch_mm, 0, 0, 0 )
            lineToA( x_mm + rw_mm, y_mm )
            lineToA( x_mm + rw_mm, y_mm + dm.cw_mm )
            lineToA( x_mm, y_mm + dm.cw_mm )
            lineToA( x_mm, y_mm )
          end
          # logo
          logo_w_mm = 17
          logo_h_mm = 18 * logo_w_mm / 15
          @img.import( 'logo.svg', x_mm + b_mm + s_mm + ( @dm.ch_mm + logo_h_mm ) / 2, y_mm + @dm.cw_mm - 1.37 * logo_w_mm, logo_w_mm, logo_h_mm, 90 )
          # mini-scales
          cm = BottomUpCmScale.new( @img, x_mm + b_mm + s_mm + @dm.ch_mm, y_mm + @dm.cw_mm, @dm.cw_mm - 5, 5 )
            cm.style = @style_cursor
            cm.render()
          inch = BottomUpInchScale.new( @img, x_mm + b_mm + s_mm, y_mm + @dm.cw_mm, @dm.cw_mm - 5, 5 )
            inch.style = @style_cursor
            inch.render()
          @img.rectangle x_mm, y_mm, b_mm, @dm.cw_mm, @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } )
          if ( @layer & Component::LAYER_REVERSE ) == 0
            # bending edges
            [ b_mm, s_mm, @dm.ch_mm, s_mm ].each do | w |
              x_mm += w
              @img.pline( x_mm, y_mm, x_mm, y_mm + @dm.hint_mm, @style )
              @img.pline( x_mm, y_mm + @dm.cw_mm, x_mm, y_mm + @dm.cw_mm - @dm.hint_mm, @style )
            end
          end
        end
        if ( @layer & Component::LAYER_REVERSE ) != 0
          # reset
          x_mm = @dm.x_mm + ( @dm.w_mm - rw_mm ) / 2
          gy_mm = dir != -1 ? y_mm : y_mm + @dm.cw_mm
          # see-through edge of cursor
          dm = @dm
          @img.path( @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } ) ) do
            moveToA( x_mm + b_mm + s_mm, gy_mm )
            arcToA( x_mm + b_mm + s_mm + dm.ch_mm, gy_mm, 0.75 * dm.ch_mm, 0.75 * dm.ch_mm, 0, 0, dir != -1 ? 0 : 1 )
            lineToA( x_mm + b_mm + s_mm + dm.ch_mm, gy_mm + dir * 16 )
            lineToA( x_mm + b_mm + s_mm, gy_mm + dir * 16 )
            lineToA( x_mm + b_mm + s_mm, gy_mm )
          end
          # invisible part of cursor transparent element
          @img.rectangle x_mm + b_mm + s_mm, y_mm + ( dir == -1 ? 2 : @dm.cw_mm - 6 ), @dm.ch_mm, 4, @style.merge( { :stroke => 'none', :fill => 'url(#glued)' } )
          # debug mode bending edges
          [ b_mm, s_mm, @dm.ch_mm, s_mm ].each do | w |
            x_mm += w
            @img.pline( x_mm, y_mm, x_mm, y_mm + @dm.cw_mm, @style, @branding.pattern )
          end
        end
      end

      # render strips and edges for cutting/bending
      public
      def render()
        @style_cursor = @style[Io::Creat::Slipstick::Entity::LOTICK]
        @style = { :"stroke-width" => 0.1, :stroke => "black", :"stroke-linecap" => "square", :fill => "none" }
        # [slide] element
        if ( !@component.nil? ) then @component.render() end

        # [transparent] elements cutting lines
        if ( @comp == COMP_TRANSP ) and ( ( @layer & Component::LAYER_FACE ) != 0 )
          style = @style.merge( { :"stroke-width" => @style[:"stroke-width"] * 2 } )
          # two stock part
          [ @dm.y_mm, @dm.y_mm + @dm.h_mm + 10 ].each do | y_mm |
            @img.line( 0, y_mm, @dm.sw_mm, y_mm, style )
            @img.line( 0, y_mm + @dm.h_mm, @dm.sw_mm, y_mm + @dm.h_mm, style )
            @img._text( @dm.sw_mm / 2, y_mm + @dm.h_mm + 5, "%s W%gmm H%gmm" % [ @i18n.string( 'part_stock' ), @dm.sw_mm, @dm.h_mm ], @style_aux )
            if not @branding.release
              @img._text( @dm.sw_mm / 2, y_mm + @dm.h_mm - 4 , @version, @style_aux )
            end
          end
          # two cursor parts
          y_mm = @dm.y_mm + 2 * @dm.h_mm + 22.5
          [ ( @dm.sw_mm / 4 ) - ( @dm.ch_mm / 2 ), ( 3 * @dm.sw_mm / 4 ) - ( @dm.ch_mm / 2 ) ].each do | x_mm |
            #x_mm = ( @dm.sw_mm - @dm.ch_mm ) / 2
            @img.line( x_mm, y_mm, x_mm - @dm.hint_mm, y_mm, style )
            @img._rtext( x_mm - 2 * @dm.hint_mm, y_mm, -90, '1', @style_aux )
            @img.line( x_mm, y_mm, x_mm, y_mm - @dm.hint_mm, style )
            @img._text( x_mm, y_mm - 2 * @dm.hint_mm, '2', @style_aux )
            @img.line( x_mm + @dm.ch_mm, y_mm, x_mm + @dm.ch_mm + @dm.hint_mm, y_mm, style )
            @img._rtext( x_mm + @dm.ch_mm + 3 * @dm.hint_mm, y_mm, -90, '1', @style_aux )
            @img.line( x_mm + @dm.ch_mm, y_mm, x_mm + @dm.ch_mm, y_mm - @dm.hint_mm, style )
            @img._text( x_mm + @dm.ch_mm, y_mm - 2 * @dm.hint_mm, '3', @style_aux )
            @img.line( x_mm - @dm.hint_mm, y_mm + @dm.cw_mm, x_mm + @dm.ch_mm + @dm.hint_mm, y_mm + @dm.cw_mm, style )
            @img._text( x_mm, y_mm + @dm.cw_mm + 3 * @dm.hint_mm, '2', @style_aux )
            @img._rtext( x_mm - 2 * @dm.hint_mm, y_mm + @dm.cw_mm, -90, '4', @style_aux )
            @img.line( x_mm, y_mm + @dm.cw_mm, x_mm, y_mm + @dm.cw_mm + @dm.hint_mm, style )
            @img._text( x_mm + @dm.ch_mm, y_mm + @dm.cw_mm + 3 * @dm.hint_mm, '3', @style_aux )
            @img.line( x_mm + @dm.ch_mm, y_mm + @dm.cw_mm, x_mm + @dm.ch_mm, y_mm + @dm.cw_mm + @dm.hint_mm, style )
            @img._rtext( x_mm + @dm.ch_mm + 3 * @dm.hint_mm, y_mm + @dm.cw_mm, -90, '4', @style_aux )
            @img._text( x_mm + @dm.ch_mm / 2, y_mm + @dm.cw_mm + 5, "%s W%gmm H%gmm" % [ @i18n.string( 'part_cursor' ), @dm.ch_mm, @dm.cw_mm ], @style_aux )
          end
        end

        # strips of scales
        super( true )
        output = ""
        @img.write(output)
        return output
      end

    end # A

  end # Model
end # Io::Creat::Slipstick

