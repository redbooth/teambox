class Magick::Image
  def dispose!
    destroy! if respond_to?(:destroy!)
  end
end