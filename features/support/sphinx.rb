require 'fileutils'

config = ThinkingSphinx::Configuration.instance
search_enabled = Teambox.config.allow_search

module TSHelpers
  def ts_reindex(rebuild = false)
    config = ThinkingSphinx::Configuration.instance

    if rebuild
      if ThinkingSphinx.sphinx_running?
        config.controller.stop
	sleep(2)
      end

      # forces rebuilding index objects to fix polymorphic associations
      ThinkingSphinx.context.indexed_models.each do |model|
        klass = model.constantize
        klass.send(:defined_indexes=, false)
        klass.sphinx_indexes.clear
        klass.sphinx_facets.clear
      end

      FileUtils.rm_rf config.searchd_file_path
      config.build
    end
    
    FileUtils.mkdir_p config.searchd_file_path
    output = config.controller.index


    
    if output =~ /^ERROR:/
      $stderr.puts output
      raise "Sphinx indexing failed"
    end

    unless ThinkingSphinx.sphinx_running?
      config.controller.start
      sleep(2)
    end
  end
end

World(TSHelpers)

Before('@sphinx') do
  Teambox.config.allow_search = true
  
  if ThinkingSphinx.sphinx_running?
    config.controller.stop
    sleep(2)
  end

  FileUtils.rm_rf config.searchd_file_path
  FileUtils.mkdir_p config.searchd_file_path

  unless ThinkingSphinx.sphinx_running?
    config.build
    output = config.controller.index
    
    if output =~ /^ERROR:/
      $stderr.puts output
      raise "Initial Sphinx indexing failed"
    end

    config.controller.start
  end
end

After('@sphinx') do
  Teambox.config.allow_search = search_enabled
end

Kernel.at_exit do
  if ThinkingSphinx.sphinx_running?
    config.controller.stop
  end
end
