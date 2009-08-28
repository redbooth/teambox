module Fleximage
  module Operator
    
    # Adds an overlay to the base image.  It's useful for things like attaching a logo,
    # watermark, or even a border to the image.  It will work best with a 24-bit PNG with
    # alpha channel since it will properly deal with partial transparency.
    # 
    #   image.resize(image_overlay_path, options = {})
    # 
    # +image_overlay_path+ is the path, relative to +RAILS_ROOT+ where the image you want superimposed
    # can be found.
    # 
    # Use the following keys in the +options+ hash:
    # 
    # * +size+: The size of the overlayed image, as <tt>'123x456'</tt> or <tt>[123, 456]</tt>.  
    #   By default the overlay is not resized before compositing.
    #   Use this options if you want to resize the overlay, perhaps to have a small
    #   logo on thumbnails and a big logo on full size images.  Other than just numerical dimensions, the
    #   size parameter takes 2 special values :+scale_to_fit+ and :+stretch_to_fit+.  :+scale_to_fit+ will 
    #   make the overlay fit as 
    #   much as it can inside the image without changing the aspect ratio.  :+stretch_to_fit+
    #   will make the overlay the exact same size as the image but with a distorted aspect ratio to make
    #   it fit.  :+stretch_to_fit+ is designed to add border to images.
    # 
    # * +alignment+: A symbol that tells Fleximage where to put the overlay.  Can be any of the following:
    #   <tt>:center, :top, :top_right, :right, :bottom_right, :bottom, :bottom_left, :left, :top_left</tt>.
    #   Default is :+center+
    # 
    # * +offset+: the number of pixels to offset the overlay from it's :+alignment+ anchor, in 
    #   <tt>'123x456'</tt> or <tt>[123, 456]</tt> format.  Useful to give a bit a space between your logo 
    #   and the edge of the image, for instance.
    #   *NOTE:* Due to some unexpected (buggy?) RMagick behaviour :+offset+ will work strangely
    #   if :+alignment+ is set to a non-corner value, such as :+top+ or :+center+.  Using :+offset+ in
    #   these cases will force the overlay into a corner anyway.
    # 
    # * +blending+: The blending mode governs how the overlay gets composited onto the image.  You can 
    #   get some funky effects with modes like :+copy_cyan+ or :+screen+.  For a full list of blending
    #   modes checkout the RMagick documentation (http://www.simplesystems.org/RMagick/doc/constants.html#CompositeOperator).
    #   To use a blend mode remove the +CompositeOp+ form the name and "unserscorize" the rest.  For instance,
    #   +MultiplyCompositeOp+ becomes :+multiply+, and +CopyBlackCompositeOp+ becomes :+copy_black+.
    #
    # Example:
    # 
    #   @photo.operate do |image|
    #     image.image_overlay('images/my_logo_with_alpha.png',
    #       :size => '25x25',
    #       :alignment => :top_right,
    #       :blending => :screen
    #     )
    #   end
    class ImageOverlay < Operator::Base
      def operate(image_overlay_path, options = {})
        options = options.symbolize_keys
      
        #load overlay
        overlay = Magick::Image.read(image_overlay_path).first
      
        #resize overlay
        if options[:size]
          if options[:size] == :scale_to_fit || options[:size] == :stretch_to_fit
            x, y = @image.columns, @image.rows
          else
            x, y = size_to_xy(options[:size])
          end
        
          method = options[:size] == :stretch_to_fit ? :stretch : :scale
          send(method, [x, y], overlay)
        end
      
        #prepare arguments for composite!
        args = []
        args << overlay                                               #overlay image
        args << symbol_to_gravity(options[:alignment] || :center)     #gravity
        args += size_to_xy(options[:offset]) if options[:offset]      #offset
        args << symbol_to_blending_mode(options[:blending] || :over)  #compositing mode
        
        #composite
        @image.composite!(*args)
      
        return @image
      end
    end
    
  end
end