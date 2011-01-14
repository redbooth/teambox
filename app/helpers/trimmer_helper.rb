module TrimmerHelper

  def trimmer_templates_include_tag
    javascript_include_tag trimmer_templates_path(I18n.locale)
  end

  def trimmer_translations_include_tag
    javascript_include_tag trimmer_translations_path(I18n.locale)
  end

  def trimmer_include_tag
    javascript_include_tag trimmer_resources_path(I18n.locale)
  end

end
