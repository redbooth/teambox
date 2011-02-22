require "tempfile"
require "yui/compressor"
require "fileutils"

APP_PATH = File.expand_path("./public/application.js")

task :build do
  `sprocketize -I public/ public/juggernaut.js > #{APP_PATH}`
end

task :compress do
  tempfile   = Tempfile.new("yui")
  compressor = YUI::JavaScriptCompressor.new(:munge => true)
  File.open(APP_PATH, "r") do |file|
    compressor.compress(file) do |compressed|
      while buffer = compressed.read(4096)
        tempfile.write(buffer)
      end
    end
  end
  
  tempfile.close
  FileUtils.mv(tempfile.path, APP_PATH)
end

task :default => [:build, :compress]