require 'tempfile'

When /^(?:|I )attach a (\d+) ?MB file to "([^\"]*)"(?: within "([^\"]*)")?$/ do |size, field, selector|
  with_scope(selector) do
    file = Tempfile.new 'cucumber_upload'
    (size.to_i * 1024).times do
      file << ('x' * 1024) << "\n"
    end
    file.close
    attach_file(field, file.path)
  end
end
