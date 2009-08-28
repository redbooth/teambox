module Fleximage
  module Operator
    
    # Trim off all the pixels around the image border that have the same color.
    #
    #   image.trim
    class Trim < Operator::Base
      def operate()
        @image.trim!(true)
      end
    end
    
  end
end