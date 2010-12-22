require 'yaml'
unless Object.const_defined?("EXTENSIONS")
  EXTENSIONS = YAML.load_file(File.dirname(__FILE__) + '/mime_types.yml')
end
