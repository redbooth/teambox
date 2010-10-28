require 'rack/utils'

# backporting a params parsing fix from Rack 1.2
module Rack::Utils
  undef normalize_params
  
  def normalize_params(params, name, v = nil)
    name =~ %r(\A[\[\]]*([^\[\]]+)\]*)
    k = $1 || ''
    after = $' || ''

    return if k.empty?

    if after == ""
      params[k] = v
    elsif after == "[]"
      params[k] ||= []
      raise TypeError, "expected Array (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Array)
      params[k] << v
    elsif after =~ %r(^\[\]\[([^\[\]]+)\]$) || after =~ %r(^\[\](.+)$)
      child_key = $1
      params[k] ||= []
      raise TypeError, "expected Array (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Array)
      if params[k].last.is_a?(Hash) && !params[k].last.key?(child_key)
        normalize_params(params[k].last, child_key, v)
      else
        params[k] << normalize_params({}, child_key, v)
      end
    else
      params[k] ||= {}
      raise TypeError, "expected Hash (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Hash)
      params[k] = normalize_params(params[k], after, v)
    end

    return params
  end
  
  module_function :normalize_params
end
