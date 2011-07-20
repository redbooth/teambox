# We add this to prevent some variable.html_class
# where variable is nil (for whatever reason,
# record not found, array empty, etc.)
class NilClass
  def html_safe
  end
end

