# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mimetype-fu}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Josh French"]
  s.date = %q{2009-06-24}
  s.description = %q{get the mimetype of a file directly in Ruby}
  s.email = %q{josh@vitamin-j.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
     "MIT-LICENSE",
     "Rakefile",
     "VERSION",
     "init.rb",
     "install.rb",
     "lib/extensions_const.rb",
     "lib/mime_types.yml",
     "lib/mimetype_fu.rb",
     "mimetype-fu.gemspec",
     "spec/fixtures/file.jpg",
     "spec/fixtures/file.rb",
     "spec/mime_type_spec.rb",
     "spec/spec_helper.rb",
     "test/mimetype_fu_test.rb",
     "uninstall.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jfrench/mimetype-fu}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{get the mimetype of a file directly in Ruby}
  s.test_files = [
    "spec/fixtures/file.rb",
     "spec/mime_type_spec.rb",
     "spec/spec_helper.rb",
     "test/mimetype_fu_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
