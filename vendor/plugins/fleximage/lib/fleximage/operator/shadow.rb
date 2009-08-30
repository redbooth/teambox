module Fleximage
  module Operator
        
    # Add a drop shadow to the image.
    #
    #   image.shadow(options = {})
    # 
    # Use the following keys in the +options+ hash:
    #
    # * +offset+: distance of the dropsahdow form the image, in FlexImage *size* format.  Positive
    #   number move it down and right, negative numbers move it up and left.
    #   
    # * +blur+: how blurry the shadow is.  Roughly corresponds to distance in pixels of the blur.
    # 
    # * +background+: a color for the background of the image.  What the shadow fades into.  
    #   Use an RMagick named color or use the +color+ method in FlexImage::Controller, or a
    #   Magick::Pixel object.
    #   
    # * +color+: color of the shadow itself.
    #   Use an RMagick named color or use the +color+ method in FlexImage::Controller, or a
    #   Magick::Pixel object.
    #   
    # * +opacity+: opacity of the shadow.  A value between 0.0 and 1.0, where 1 is opaque and 0 is
    #   transparent.
    # 
    # Example:
    # 
    #   @photo.operate do |image|
    #     # Default settings
    #     image.shadow(
    #       :color      => 'black',    # or color(0, 0, 0)
    #       :background => 'white',    # or color(255, 255, 255)
    #       :blur       => 8,
    #       :offset     => '2x2',
    #       :opacity    => 0.75 
    #     )
    #     
    #     # Huge, red shadow
    #     image.shadow(
    #       :color      => color(255, 0, 0),
    #       :background => 'black',    # or color(255, 255, 255)
    #       :blur       => 30,
    #       :offset     => '20x10',
    #       :opacity    => 1
    #     )
    #   end
    class Shadow < Operator::Base
      def operate(options = {})
        options = options.symbolize_keys if options.respond_to?(:symbolize_keys)
        defaults = {
          :offset     => 2,
          :blur       => 8,
          :background => 'white',
          :color      => 'black',
          :opacity    => 0.75
        }
        options = options.is_a?(Hash) ? defaults.update(options) : defaults

        # verify options
        options[:offset] = size_to_xy(options[:offset])
        options[:blur]   = options[:blur].to_i

        options[:background]    = Magick::Pixel.from_color(options[:background]) unless options[:background].is_a?(Magick::Pixel)
        options[:color]         = Magick::Pixel.from_color(options[:color])      unless options[:color].is_a?(Magick::Pixel)
        options[:color].opacity = (1 - options[:opacity]) * 255

        # generate shadow image
        shadow = @image.dup
        shadow.background_color = options[:color]
        shadow.erase!
        shadow.border!(options[:offset].max + options[:blur] * 3, options[:offset].max + options[:blur] * 3, options[:background])
        shadow = shadow.blur_image(0, options[:blur] / 2)

        # apply shadow
        @image = shadow.composite(
          @image, 
          symbol_to_gravity(:top_left), 
          (shadow.columns - @image.columns) / 2 - options[:offset][0], 
          (shadow.rows    - @image.rows)    / 2 - options[:offset][1], 
          symbol_to_blending_mode(:over)
        )
        @image.trim!
      end
    end
    
  end
end