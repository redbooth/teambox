require "jammit"

module Jammit
  def self.package!(options={})
    options = {
      :config_path    => Jammit::DEFAULT_CONFIG_PATH,
      :output_folder  => nil,
      :base_url       => nil,
      :force          => false
    }.merge(options)
    packager.force = options[:force]
    packager.precache_all(options[:output_folder], options[:base_url])
  end
end
