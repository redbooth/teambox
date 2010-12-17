module Immortal
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      class << self
        alias :mortal_delete_all :delete_all
        alias :delete_all :immortal_delete_all
      end
    end
  end

  module ClassMethods

    def with_deleted
      unscoped
    end
    
    def only_deleted
      unscoped.where(:deleted => true)
    end

    def count_with_deleted(*args)
      with_deleted.count(*args)
    end

    def count_only_deleted(*args)
      only_deleted.count(*args)
    end    

    def find_with_deleted(*args)
      with_deleted.find(*args)
    end
    
    def find_only_deleted(*args)
      only_deleted.find(*args)
    end

    def immortal_delete_all(*args)
      unscoped.update_all ["deleted = ?", true]
    end

    def delete_all!(*args)
      unscoped.mortal_delete_all
    end

  end
  
  module InstanceMethods    
    def self.included(base)
      base.class_eval do
        default_scope where(["deleted IS NULL OR deleted = ?", false])
        alias :mortal_destroy :destroy
        alias :destroy :immortal_destroy
      end
    end

    def immortal_destroy(*args)
      run_callbacks :destroy do
        destroy_without_callbacks(*args)
      end
    end
    
    def destroy!(*args)
      mortal_destroy
    end

    def destroy_without_callbacks(*args)
      self.class.unscoped.update_all ["deleted = ?", true], "id = #{self.id}"
      reload
      freeze
    end
    
    def recover!
      self.class.unscoped.update_all ["deleted = ?", false], "id = #{self.id}"
      reload
    end

  end
end
