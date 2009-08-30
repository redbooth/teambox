module Fleximage
  
  # An instance of this class is yielded when Model#operate is called.  It enables image operators
  # to be called to transform the image.  You should never need to directly deal with this class.
  # You simply call image operators on this object when inside an Model#operate block
  #
  #   @photo.operate do |image|
  #     image.resize '640x480'
  #   end
  #
  # In this example, +image+ is an instance of ImageProxy
  class ImageProxy
    
    class OperatorNotFound < NameError #:nodoc:
    end
    
    # The image to be manipulated by operators.
    attr_accessor :image
    
    # Create a new image operator proxy.
    def initialize(image, model_obj)
      @image = image
      @model = model_obj
    end

    # Shortcut for accessing current image width
    def width
      @image.columns
    end

    # Shortcut for accessing current image height
    def height
      @image.rows
    end
    
    # A call to an unknown method will look for an Operator by that method's name.
    # If it finds one, it will execute that operator.
    def method_missing(method_name, *args)
      # Find the operator class
      class_name = method_name.to_s.camelcase
      operator_class = "Fleximage::Operator::#{class_name}".constantize
      
      # Define a method for this operator so future calls to this operation are faster
      self.class.module_eval <<-EOF
        def #{method_name}(*args)
          @image = execute_operator(#{operator_class}, *args)
        end
      EOF
      
      # Call the method that was just defined to perform its functionality.
      send(method_name, *args)
    
    rescue NameError => e
      if e.to_s =~ /uninitialized constant Fleximage::Operator::#{class_name}/
        raise OperatorNotFound, "No operator Fleximage::Operator::#{class_name} found for the method \"#{method_name}\""
      else
        raise e
      end
    end
    
    private
      # Instantiate and execute the requested image Operator.
      def execute_operator(operator_class, *args)
        operator_class.new(self, @image, @model).execute(*args)
      end
    
  end
  
end