module Sprockets
  class SourceLine
    protected
    # We disable constant interpolation
    def interpolate_constants!(*args)
    end
  end
end

