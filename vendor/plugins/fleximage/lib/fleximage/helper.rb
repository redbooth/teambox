module Fleximage
  module Helper
    
    # Creates an image tag that links directly to image data.  Recommended for displays of a
    # temporary upload that is not saved to a record in the databse yet.
    def embedded_image_tag(model, options = {})
      model.load_image
      format  = options[:format] || :jpg
      mime    = Mime::Type.lookup_by_extension(format.to_s).to_s
      image   = model.output_image(:format => format)
      data    = Base64.encode64(image)
      
      options = { :alt => model.class.to_s }.merge(options)
      
      result = image_tag("data:#{mime};base64,#{data}", options)
      result.gsub(%r{src=".*/images/data:}, 'src="data:')
      
    rescue Fleximage::Model::MasterImageNotFound => e
      nil
    end
    
    # Creates a link that opens an image for editing in Aviary.
    #
    # Options:
    # 
    # * image_url: url to the master image used by Aviary for editing.  Defauls to <tt>url_for(:action => 'aviary_image', :id => model, :only_path => false)</tt>
    # * post_url:  url where Aviary will post the updated image.  Defauls to <tt>url_for(:action => 'aviary_image_update', :id => model, :only_path => false)</tt>
    #
    # All other options are passed directly to the @link_to@ helper.
    def link_to_edit_in_aviary(text, model, options = {})
      key       = aviary_image_hash(model)
      image_url = options.delete(:image_url)        || url_for(:action => 'aviary_image',        :id => model, :only_path => false, :key => key)
      post_url  = options.delete(:image_update_url) || url_for(:action => 'aviary_image_update', :id => model, :only_path => false, :key => key)
      api_key   = Fleximage::AviaryController.api_key
      url       = "http://aviary.com/flash/aviary/index.aspx?tid=1&phoenix&apil=#{api_key}&loadurl=#{CGI.escape image_url}&posturl=#{CGI.escape post_url}"
      
      link_to text, url, { :target => 'aviary' }.merge(options)
    end
    
  end
end
