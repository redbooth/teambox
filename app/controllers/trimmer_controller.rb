# Based largely on fnando's i18n-js gem
module I18n
  extend self

  # deep_merge by Stefan Rusterholz, see http://www.ruby-forum.com/topic/142809
  MERGER = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &MERGER) : v2 }

  # Exports translations from the I18n backend to a Hash
  # :locale. If specified, will dump only translations for the given locale.
  # :only. If specified, will dump only keys that match the pattern. "*.date"
  def to_hash options = {}
    options.reverse_merge!(:only => "*")

    if options[:only] == "*"
      data = translations
    else
      data = scoped_translations options[:only]
    end

    if options[:locale]
      data[options[:locale].to_sym]
    else
      data
    end
  end

  def scoped_translations(scopes) # :nodoc:
    result = {}

    [scopes].flatten.each do |scope|
      deep_merge! result, filter(translations, scope)
    end

    result
  end

  # Filter translations according to the specified scope.
  def filter(translations, scopes)
    scopes = scopes.split(".") if scopes.is_a?(String)
    scopes = scopes.clone
    scope = scopes.shift

    if scope == "*"
      results = {}
      translations.each do |scope, translations|
        tmp = scopes.empty? ? translations : filter(translations, scopes)
        results[scope.to_sym] = tmp unless tmp.nil?
      end
      return results
    elsif translations.has_key?(scope.to_sym)
      return {scope.to_sym => scopes.empty? ? translations[scope.to_sym] : filter(translations[scope.to_sym], scopes)}
    end
    nil
  end

  # Initialize and return translations
  def translations
    self.backend.instance_eval do
      init_translations unless initialized?
      translations
    end
  end

  def deep_merge!(target, hash) # :nodoc:
    target.merge!(hash, &MERGER)
  end
end




class TrimmerController < ActionController::Base

  caches_page :templates
  caches_page :translations
  caches_page :resources

  def templates
    render :text => templates_to_js(:locale => params[:locale]), :content_type => 'text/javascript'
  end

  KEYS = ["*.date", "*.datetime", "*.calendar", "*.time", "*.comments.new.assigned_to_nobody"]

  def translations
    render :text => translations_to_js(:locale => params[:locale], :only => KEYS), :content_type => 'text/javascript'
  end 

  # Exports templates and translations in a single request
  def resources
    render :text => translations_to_js(:locale => params[:locale], :only => KEYS) + "\n" +
                    templates_to_js(:locale => params[:locale]), :content_type => 'text/javascript'
  end

  protected

    # Gets all templates and renders them as JSON, to be used as Mustache templates
    def templates_to_js(options)
      old_locale = I18n.locale
      I18n.locale = options[:locale]
      base_path = Rails.root.join("app/templates")
      templates = JSON.dump(get_templates_from(base_path))
      I18n.locale = old_locale
      "Templates = (#{templates});"
    end

    # Traverses recursively base_path and fetches templates
    def get_templates_from(base_path)
      templates = {}
      entries = Dir.entries(base_path)
      entries.shift(2)
      entries.each do |entry|
        path = File.join(base_path, entry)
        if File.directory? path
          templates[entry] = get_templates_from path
        elsif File.file? path
          name = entry.split('.').first
          if !name.empty?
            templates[name] = render_to_string(:file => path, :layout => false)
          end
        end
      end
      templates
    end

    # Dumps all the translations. Options you can pass:
    # :locale. If specified, will dump only translations for the given locale.
    # :only. If specified, will dump only keys that match the pattern. "*.date"
    def translations_to_js(options = {})
      "if(typeof(I18n) == 'undefined') { I18n = {}; };\n" +
      "I18n.translations = (#{I18n.to_hash(options).to_json});"
    end
end
