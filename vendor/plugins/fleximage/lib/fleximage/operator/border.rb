module Fleximage
  module Operator
        
    # Add a border to the outside of the image
    #
    #   image.border(options = {})
    # 
    # Use the following keys in the +options+ hash:
    #
    # * +size+: Width of the border on each side.  You can use a 2 dimensional value ('5x10') if you want
    #   different widths for the sides and top borders, but a single integer will apply the same border on 
    #   all sides.
    #   
    # * +color+: the color of the border. Use an RMagick named color or use the +color+ method in 
    #   FlexImage::Controller, or a Magick::Pixel object.
    #   
    # Example:
    #   
    #   @photo.operate do |image|
    #     # Defaults
    #     image.border(
    #       :size  => 10,
    #       :color => 'white'    # or color(255, 255, 255)
    #     )
    #     
    #     # Big, pink and wide
    #     image.border(
    #       :size  => '200x100',
    #       :color => color(255, 128, 128)
    #     )
    #   end
    class Border < Operator::Base
      def operate(options = {})
        options = options.symbolize_keys if options.respond_to?(:symbolize_keys)
        defaults = {
          :size => '10',
          :color => 'white'
        }
        options = options.is_a?(Hash) ? defaults.update(options) : defaults
        
        # Get border size
        options[:size] = size_to_xy(options[:size])

        # apply border
        @image.border!(options[:size][0], options[:size][1], options[:color])
      end
    end
    
  end
end