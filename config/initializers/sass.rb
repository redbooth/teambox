# for Haml versions 2.2.x
module Sass::Script::Functions
  def rgba(color, opacity)
    values = color.value + [opacity]
    Sass::Script::String.new('rgba(%d,%d,%d,%s)' % values)
  end
end
