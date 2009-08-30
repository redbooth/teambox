module Fleximage
  module Operator

    # Composites a transparent image over a colored backgroud
    #
    # It accepts the following options:
    #
    # * +color+: the color of the background image.
    #   Use an RMagick named color or use the +color+ method in Fleximage::Controller, or a
    #   Magick::Pixel object.
    # 
    # * +size+: The size of the background image, in Fleximage *size* format.  
    #   By default the background image is the same size as the foreground image
    # 
    # * +alignment+: A symbol that tells Fleximage where to put the foreground image on 
    #   top of the background image.  Can be any of the following:
    #   <tt>:center, :top, :top_right, :right, :bottom_right, :bottom, :bottom_left, :left, :top_left</tt>.
    #   Default is :+center+
    # 
    # * +offset+: the number of pixels to offset the foreground image from it's :+alignment+ anchor, in FlexImage 
    #   *size* format.  Useful to give a bit a space between your image and the edge of the background, for instance.
    #   *NOTE:* Due to some unexpected (buggy?) RMagick behaviour :+offset+ will work strangely
    #   if :+alignment+ is set to a corner non-corner value, such as :+top+ or :+center+.  Using :+offset+ in
    #   these cases will force the overlay into a corner anyway.
    # 
    # * +blending+: The blending mode governs how the foreground image gets composited onto the background.  You can 
    #   get some funky effects with modes like :+copy_cyan+ or :+screen+.  For a full list of blending
    #   modes checkout the RMagick documentation (http://www.simplesystems.org/RMagick/doc/constants.html#CompositeOperator).
    #   To use a blend mode remove the +CompositeOp+ form the name and "unserscorize" the rest.  For instance,
    #   +MultiplyCompositeOp+ becomes :+multiply+, and +CopyBlackCompositeOp+ becomes :+copy_black+.

    class Background < Operator::Base 
      def operate(options = {})
        options = options.symbolize_keys

        #default to a white background if the color option is not set
        color = options[:color] || 'white'

        #use the existing image's size if the size option is not set
        width, height = options.key?(:size) ? size_to_xy(options[:size]) : [@image.columns, @image.rows]

        #create the background image onto which we will composite the foreground image
        bg = Magick::Image.new(width, height) do 
          self.background_color = color
          self.format = 'PNG'
        end

        #prepare attributes for composite operation
        args = []
        args << @image
        args << symbol_to_gravity(options[:alignment] || :center)
        args += size_to_xy(options[:offset]) if options[:offset]
        args << symbol_to_blending_mode(options[:blending] || :over)

        #composite the foreground image onto the background
        bg.composite!(*args)

        return bg
      end
    end
  end
end
