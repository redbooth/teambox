require 'tempfile'
require 'extensions_const'

class File

  def self.mime_type?(file)
    case file
    when File, Tempfile
      unless RUBY_PLATFORM.include? 'mswin32'
        mime = `file --mime-type -br "#{file.path}"`.strip
      else
        mime = EXTENSIONS[File.extname(file.path).gsub('.','').downcase.to_sym]
      end
    when String
        mime = EXTENSIONS[File.extname(file).delete('.').downcase.to_sym] unless file.match(/\.\w+$/).nil?
    when StringIO
      temp = File.open(Dir.tmpdir + '/upload_file.' + Process.pid.to_s, "wb")
      temp << file.string
      temp.close
      mime = `file --mime-type -br "#{temp.path}"`
      mime = mime.gsub(/^.*: */,"")
      mime = mime.gsub(/;.*$/,"")
      mime = mime.gsub(/,.*$/,"")
      File.delete(temp.path)
    end
    mime || 'unknown/unknown'
   end

  def self.extensions
    EXTENSIONS
  end

end
