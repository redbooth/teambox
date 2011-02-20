module Caboose # :nodoc:
  module Acts # :nodoc:
    class BelongsToWithDeletedPolymorphicAssociation < ActiveRecord::Associations::BelongsToPolymorphicAssociation
      private
        def find_target
          return nil if association_class.nil?
          if @reflection.options[:conditions]
            association_class.find_with_deleted(
              @owner[@reflection.primary_key_name],
              :select     => @reflection.options[:select],
              :conditions => conditions,
              :include    => @reflection.options[:include]
            )
          else
            association_class.find_with_deleted(@owner[@reflection.primary_key_name], :select => @reflection.options[:select], :include => @reflection.options[:include])
          end
        end
    end
  end
end