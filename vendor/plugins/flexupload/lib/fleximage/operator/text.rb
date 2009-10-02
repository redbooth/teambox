module Fleximage
  module Operator
    
    # Draw text on the image.  Customize size, position, color, dropshadow, and font.
    # 
    #   image.text(string_to_write, options = {})
    #
    # Use the following keys in the +options+ hash:
    # 
    # * alignment: symbol like in <tt>ImageOverlay</tt>
    # * offset: size string
    # * antialias: true or false
    # * color: string or <tt>color(r, g, b)</tt>
    # * font_size: integer
    # * font: path to a font file relative to +RAILS_ROOT+
    # * rotate: degrees as an integer
    # * shadow: <tt>{:blur => 1, :opacity => 1.0}</tt>
    # * font_weight: RMagick font weight constant or value. See: http://www.imagemagick.org/RMagick/doc/draw.html#font_weight
    # * stroke: hash that, if present, will stroke the text.  The hash should have both <tt>:width</tt> (integer) and <tt>:color</tt> (string or color object).
    #
    # Example:
    #
    #   @photo.operate do |image|
    #     image.text('I like Cheese',
    #       :alignment => :top_left,
    #       :offset => '300x150',
    #       :antialias => true,
    #       :color => 'pink',
    #       :font_size => 24,
    #       :font => 'path/to/myfont.ttf',
    #       :rotate => -15,
    #       :shadow => {
    #         :blur => 1,
    #         :opacity => 0.5,
    #       },
    #       :stroke => {
    #         :width => 3,
    #         :color => color(0, 0, 0),
    #       }
    #     )
    #   end
    class Text < Operator::Base
      def operate(string_to_write, options = {})
        options = {
          :alignment  => :top_left,
          :offset     => '0x0',
          :antialias  => true,
          :color      => 'black',
          :font_size  => '12',
          :font       => nil,
          :text_align => :left,
          :rotate     => 0,
          :shadow     => nil,
          :stroke     => {
            :width => 0,
            :color => 'white',
          }
        }.merge(options)
        options[:offset] = size_to_xy(options[:offset])

        # prepare drawing surface
        text                = Magick::Draw.new
        text.gravity        = symbol_to_gravity(options[:alignment])
        text.fill           = options[:color]
        text.text_antialias = options[:antialias]
        text.pointsize      = options[:font_size].to_i
        text.rotation       = options[:rotate]
        text.font_weight    = options[:font_weight] if options[:font_weight]
        
        if options[:stroke][:width] > 0
          text.stroke_width   = options[:stroke][:width]
          text.stroke         = options[:stroke][:color]
        end

        # assign font path with to rails root unless the path is absolute
        if options[:font]
          font = options[:font]
          font = "#{RAILS_ROOT}/#{font}" unless font =~ %r{^(~?|[A-Za-z]:)/}
          text.font = font
        end

        # draw text on transparent image
        temp_image = Magick::Image.new(@image.columns, @image.rows) { self.background_color = 'none' }
        temp_image = temp_image.annotate(text, 0, 0, options[:offset][0], options[:offset][1], string_to_write)

        # add drop shadow to text image
        if options[:shadow]
          shadow_args = [2, 2, 1, 1]
          if options[:shadow].is_a?(Hash)
            #shadow_args[0], shadow_args[1] = size_to_xy(options[:shadow][:offset]) if options[:shadow][:offset]
            shadow_args[2] = options[:shadow][:blur]                               if options[:shadow][:blur]
            shadow_args[3] = options[:shadow][:opacity]                            if options[:shadow][:opacity]
          end
          shadow = temp_image.shadow(*shadow_args)
          temp_image = shadow.composite(temp_image, 0, 0, symbol_to_blending_mode(:over))
        end

        # composite text on original image
        @image.composite!(temp_image, 0, 0, symbol_to_blending_mode(:over))
      end
    end
    
  end
end