require 'active_support' unless defined?(ActiveSupport)

class Class
  def dsl_accessor(name, options = {})
    raise TypeError, "DSL Error: options should be a hash. but got `#{options.class}'" unless options.is_a?(Hash)
    writer = options[:writer] || options[:setter]
    writer =
      case writer
      when NilClass then Proc.new{|value| value}
      when Symbol   then Proc.new{|value| __send__(writer, value)}
      when Proc     then writer
      else raise TypeError, "DSL Error: writer should be a symbol or proc. but got `#{options[:writer].class}'"
      end
    write_inheritable_attribute(:"#{name}_writer", writer)

    default =
      case options[:default]
      when NilClass then nil
      when []       then Proc.new{[]}
      when {}       then Proc.new{{}}
      when Symbol   then Proc.new{__send__(options[:default])}
      when Proc     then options[:default]
      else Proc.new{options[:default]}
      end
    write_inheritable_attribute(:"#{name}_default", default)

    self.class.class_eval do
      define_method("#{name}=") do |value|
        writer = read_inheritable_attribute(:"#{name}_writer")
        value  = writer.call(value) if writer
        write_inheritable_attribute(:"#{name}", value)
      end

      define_method(name) do |*values|
        if values.empty?
          # getter method
          key = :"#{name}"
          if !inheritable_attributes.has_key?(key)
            default = read_inheritable_attribute(:"#{name}_default")
            value   = default ? default.call(self) : nil
            __send__("#{name}=", value)
          end
          read_inheritable_attribute(key)
        else
          # setter method
          __send__("#{name}=", *values)
        end
      end
    end
  end
end

